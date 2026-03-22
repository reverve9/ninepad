-- =============================================================
-- NinePAD — RLS 무한 재귀 최종 수정
-- 원인: 모든 RLS 정책이 동시 평가되면서 users 서브쿼리가 재귀
-- 해결: SECURITY DEFINER 함수로 RLS 우회하여 본인 정보 조회
-- =============================================================

-- 1. 기존 문제 정책 전부 삭제
DROP POLICY IF EXISTS "users_select_same_org" ON users;
DROP POLICY IF EXISTS "users_select_superadmin" ON users;
DROP POLICY IF EXISTS "users_select_self" ON users;
DROP POLICY IF EXISTS "users_select_all_for_superadmin" ON users;

-- 2. SECURITY DEFINER 함수 생성 (RLS 우회)

-- 본인 org_id 조회
CREATE OR REPLACE FUNCTION auth_user_org_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT org_id FROM users WHERE id = auth.uid()
$$;

-- 본인 role 조회
CREATE OR REPLACE FUNCTION auth_user_role()
RETURNS TEXT
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT role FROM users WHERE id = auth.uid()
$$;

-- 3. 새 RLS 정책 (서브쿼리 대신 함수 사용 → 재귀 없음)

-- 본인 레코드
CREATE POLICY "users_select_self" ON users
    FOR SELECT USING (id = auth.uid());

-- 같은 org 멤버
CREATE POLICY "users_select_same_org" ON users
    FOR SELECT USING (
        org_id IS NOT NULL
        AND org_id = auth_user_org_id()
    );

-- 슈퍼어드민은 모든 유저 조회
CREATE POLICY "users_select_all_superadmin" ON users
    FOR SELECT USING (auth_user_role() = 'superadmin');

-- 4. organizations 정책도 함수 사용으로 변경
DROP POLICY IF EXISTS "org_select_superadmin" ON organizations;
DROP POLICY IF EXISTS "org_update_superadmin" ON organizations;

CREATE POLICY "org_select_superadmin" ON organizations
    FOR SELECT USING (auth_user_role() = 'superadmin');

CREATE POLICY "org_update_superadmin" ON organizations
    FOR UPDATE USING (auth_user_role() = 'superadmin');
