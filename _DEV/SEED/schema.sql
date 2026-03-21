-- =============================================================
-- NinePAD — Supabase Multi-tenant Schema
-- Phase 1: 테이블 + RLS (Row Level Security)
-- 순서: 테이블 전체 생성 → RLS 활성화 → 정책 적용
-- =============================================================

-- 0. UUID 확장 (Supabase에서 기본 활성화지만 명시)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================
-- STEP 1: 테이블 생성 (의존 순서: organizations → users → 나머지)
-- =============================================================

CREATE TABLE IF NOT EXISTS organizations (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS users (
    id         UUID PRIMARY KEY,  -- auth.users.id 와 동일
    org_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    email      TEXT NOT NULL,
    role       TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS memos (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    org_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    title      TEXT NOT NULL DEFAULT '',
    content    TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS snippets (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    org_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    title      TEXT NOT NULL DEFAULT '',
    content    TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS invitations (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id      UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    email       TEXT NOT NULL,
    token       TEXT NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(32), 'hex'),
    expires_at  TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '7 days'),
    accepted_at TIMESTAMPTZ
);

-- =============================================================
-- STEP 2: 트리거
-- =============================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER memos_updated_at
    BEFORE UPDATE ON memos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- =============================================================
-- STEP 3: RLS 활성화
-- =============================================================

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE memos ENABLE ROW LEVEL SECURITY;
ALTER TABLE snippets ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;

-- =============================================================
-- STEP 4: RLS 정책 (users 테이블이 이미 존재하므로 안전)
-- =============================================================

-- organizations
CREATE POLICY "org_select_own" ON organizations
    FOR SELECT USING (
        id IN (SELECT org_id FROM users WHERE id = auth.uid())
    );

CREATE POLICY "org_insert" ON organizations
    FOR INSERT WITH CHECK (true);

-- users
CREATE POLICY "users_select_same_org" ON users
    FOR SELECT USING (
        org_id IN (SELECT org_id FROM users WHERE id = auth.uid())
    );

CREATE POLICY "users_insert_self" ON users
    FOR INSERT WITH CHECK (id = auth.uid());

CREATE POLICY "users_update_self" ON users
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- memos
CREATE POLICY "memos_select_same_org" ON memos
    FOR SELECT USING (
        org_id IN (SELECT org_id FROM users WHERE id = auth.uid())
    );

CREATE POLICY "memos_insert_own" ON memos
    FOR INSERT WITH CHECK (
        user_id = auth.uid()
        AND org_id IN (SELECT org_id FROM users WHERE id = auth.uid())
    );

CREATE POLICY "memos_update_own" ON memos
    FOR UPDATE USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "memos_delete_own" ON memos
    FOR DELETE USING (user_id = auth.uid());

-- snippets
CREATE POLICY "snippets_select_same_org" ON snippets
    FOR SELECT USING (
        org_id IN (SELECT org_id FROM users WHERE id = auth.uid())
    );

CREATE POLICY "snippets_insert_own" ON snippets
    FOR INSERT WITH CHECK (
        user_id = auth.uid()
        AND org_id IN (SELECT org_id FROM users WHERE id = auth.uid())
    );

CREATE POLICY "snippets_update_own" ON snippets
    FOR UPDATE USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "snippets_delete_own" ON snippets
    FOR DELETE USING (user_id = auth.uid());

-- invitations
CREATE POLICY "invitations_insert_admin" ON invitations
    FOR INSERT WITH CHECK (
        org_id IN (
            SELECT org_id FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "invitations_select_admin" ON invitations
    FOR SELECT USING (
        org_id IN (
            SELECT org_id FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "invitations_select_by_token" ON invitations
    FOR SELECT USING (true);

CREATE POLICY "invitations_update_accept" ON invitations
    FOR UPDATE USING (true)
    WITH CHECK (accepted_at IS NOT NULL);

-- =============================================================
-- STEP 5: 인덱스
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_users_org_id ON users(org_id);
CREATE INDEX IF NOT EXISTS idx_memos_org_id ON memos(org_id);
CREATE INDEX IF NOT EXISTS idx_memos_user_id ON memos(user_id);
CREATE INDEX IF NOT EXISTS idx_snippets_org_id ON snippets(org_id);
CREATE INDEX IF NOT EXISTS idx_snippets_user_id ON snippets(user_id);
CREATE INDEX IF NOT EXISTS idx_invitations_org_id ON invitations(org_id);
CREATE INDEX IF NOT EXISTS idx_invitations_token ON invitations(token);
CREATE INDEX IF NOT EXISTS idx_invitations_email ON invitations(email);
