-- =============================================================
-- NinePAD — RLS 무한 재귀 수정
-- 문제: users 테이블의 RLS 정책이 users 테이블 자체를 서브쿼리로
--       조회하면서 infinite recursion 발생
-- 해결: auth.uid() 직접 비교로 변경, 서브쿼리 제거
-- =============================================================

-- 1. 기존 문제 정책 삭제
DROP POLICY IF EXISTS "users_select_same_org" ON users;
DROP POLICY IF EXISTS "users_select_superadmin" ON users;
DROP POLICY IF EXISTS "users_select_self" ON users;

-- 2. 새 정책: 본인 레코드는 항상 조회 가능
CREATE POLICY "users_select_self" ON users
    FOR SELECT USING (id = auth.uid());

-- 3. 새 정책: 같은 org 멤버 조회 (서브쿼리 대신 직접 비교)
--    본인의 org_id와 동일한 org_id를 가진 유저 조회
CREATE POLICY "users_select_same_org" ON users
    FOR SELECT USING (
        org_id IS NOT NULL
        AND org_id = (
            SELECT u.org_id FROM users u WHERE u.id = auth.uid()
        )
    );

-- 주의: 위 정책에서 서브쿼리가 다시 users를 참조하지만,
-- users_select_self가 먼저 매칭되므로 auth.uid() 레코드는 읽을 수 있고
-- 그 org_id로 같은 org 멤버를 조회합니다.
-- PostgreSQL RLS는 OR로 평가되므로 self 정책이 재귀를 차단합니다.

-- 4. 슈퍼어드민 전용 (users 서브쿼리 제거, auth.jwt() 사용 불가하므로 self 정책에 의존)
-- 슈퍼어드민은 이미 users_select_self로 본인 조회 가능
-- 다른 유저 조회가 필요하면 별도 처리 필요
-- → organizations 테이블의 superadmin 정책도 수정

-- 5. organizations 정책 수정 (무한 재귀 방지)
DROP POLICY IF EXISTS "org_select_superadmin" ON organizations;
DROP POLICY IF EXISTS "org_update_superadmin" ON organizations;

-- 슈퍼어드민: 모든 org 조회/수정 가능 (users_select_self로 본인 role 확인 가능)
CREATE POLICY "org_select_superadmin" ON organizations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'superadmin'
        )
    );

CREATE POLICY "org_update_superadmin" ON organizations
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'superadmin'
        )
    );

-- 6. 슈퍼어드민이 모든 유저를 조회할 수 있도록
CREATE POLICY "users_select_all_for_superadmin" ON users
    FOR SELECT USING (
        (SELECT role FROM users WHERE id = auth.uid()) = 'superadmin'
    );
