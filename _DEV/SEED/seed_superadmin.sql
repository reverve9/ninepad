-- =============================================================
-- NinePAD — 슈퍼어드민 시드
--
-- 사용법:
-- 1. Supabase Dashboard → Authentication → Users에서
--    reverve9@gmail.com / 123456 으로 사용자 생성
-- 2. 생성된 user의 UUID를 복사
-- 3. 아래 SQL에서 'AUTH_USER_UUID_HERE'를 실제 UUID로 교체
-- 4. SQL Editor에서 실행
-- =============================================================

-- 슈퍼어드민 등록 (org_id NULL, role superadmin)
INSERT INTO users (id, org_id, email, role)
VALUES (
    'AUTH_USER_UUID_HERE',  -- ← Supabase Auth에서 생성된 UUID로 교체
    NULL,
    'reverve9@gmail.com',
    'superadmin'
);
