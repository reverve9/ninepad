-- =============================================================
-- NinePAD — 슈퍼어드민 + Org 승인 마이그레이션
-- 기존 schema.sql 실행 후 이 파일 실행
-- =============================================================

-- 1. organizations에 status 컬럼 추가
ALTER TABLE organizations
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected'));

-- 기존 org가 있으면 approved로 변경
UPDATE organizations SET status = 'approved' WHERE status = 'pending';

-- 2. users role에 superadmin 추가
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check
    CHECK (role IN ('superadmin', 'admin', 'member'));

-- 3. users의 org_id를 nullable로 변경 (슈퍼어드민은 org 없이 존재)
ALTER TABLE users ALTER COLUMN org_id DROP NOT NULL;

-- 4. 슈퍼어드민 전용 RLS 정책 추가

-- 슈퍼어드민은 모든 org 조회 가능
CREATE POLICY "org_select_superadmin" ON organizations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'superadmin'
        )
    );

-- 슈퍼어드민은 org 업데이트 가능 (status 변경)
CREATE POLICY "org_update_superadmin" ON organizations
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'superadmin'
        )
    );

-- 슈퍼어드민은 모든 users 조회 가능
CREATE POLICY "users_select_superadmin" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.id = auth.uid() AND u.role = 'superadmin'
        )
    );

-- 5. org_id가 null인 슈퍼어드민도 users insert 가능하도록
-- 기존 users_insert_self 정책은 유지 (id = auth.uid() 체크)

-- 6. approved된 org만 데이터 접근 가능하도록 memos/snippets 정책 강화
-- (기존 RLS가 org_id 기준이므로, approved 체크는 앱 레벨에서 처리)

-- =============================================================
-- 인덱스
-- =============================================================
CREATE INDEX IF NOT EXISTS idx_organizations_status ON organizations(status);
