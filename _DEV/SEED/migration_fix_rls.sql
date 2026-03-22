-- =============================================================
-- NinePAD — RLS 수정: 본인 레코드 항상 조회 가능
-- migration_superadmin.sql 실행 후 이 파일 실행
-- =============================================================

-- 본인 레코드는 항상 조회 가능 (org_id 관계없이)
CREATE POLICY "users_select_self" ON users
    FOR SELECT USING (id = auth.uid());
