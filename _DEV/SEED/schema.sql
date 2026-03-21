-- =============================================================
-- NinePAD — Supabase Multi-tenant Schema
-- Phase 1: 테이블 + RLS (Row Level Security)
-- =============================================================

-- 0. UUID 확장 (Supabase에서 기본 활성화지만 명시)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================
-- 1. organizations
-- =============================================================
CREATE TABLE IF NOT EXISTS organizations (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- 인증된 사용자가 자기 org만 조회
CREATE POLICY "org_select_own" ON organizations
    FOR SELECT USING (
        id IN (
            SELECT org_id FROM users WHERE id = auth.uid()
        )
    );

-- 누구나 org 생성 가능 (관리자 가입 시)
CREATE POLICY "org_insert" ON organizations
    FOR INSERT WITH CHECK (true);

-- =============================================================
-- 2. users
-- =============================================================
CREATE TABLE IF NOT EXISTS users (
    id         UUID PRIMARY KEY,  -- auth.users.id 와 동일
    org_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    email      TEXT NOT NULL,
    role       TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 같은 org 멤버만 조회
CREATE POLICY "users_select_same_org" ON users
    FOR SELECT USING (
        org_id IN (
            SELECT org_id FROM users WHERE id = auth.uid()
        )
    );

-- 본인 레코드 삽입 (가입 시)
CREATE POLICY "users_insert_self" ON users
    FOR INSERT WITH CHECK (id = auth.uid());

-- 본인 레코드만 수정
CREATE POLICY "users_update_self" ON users
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- =============================================================
-- 3. memos
-- =============================================================
CREATE TABLE IF NOT EXISTS memos (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    org_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    title      TEXT NOT NULL DEFAULT '',
    content    TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE memos ENABLE ROW LEVEL SECURITY;

-- 같은 org 멤버만 조회
CREATE POLICY "memos_select_same_org" ON memos
    FOR SELECT USING (
        org_id IN (
            SELECT org_id FROM users WHERE id = auth.uid()
        )
    );

-- 본인만 생성 (org_id도 본인 것이어야 함)
CREATE POLICY "memos_insert_own" ON memos
    FOR INSERT WITH CHECK (
        user_id = auth.uid()
        AND org_id IN (
            SELECT org_id FROM users WHERE id = auth.uid()
        )
    );

-- 본인 메모만 수정
CREATE POLICY "memos_update_own" ON memos
    FOR UPDATE USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- 본인 메모만 삭제
CREATE POLICY "memos_delete_own" ON memos
    FOR DELETE USING (user_id = auth.uid());

-- updated_at 자동 갱신 트리거
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
-- 4. snippets
-- =============================================================
CREATE TABLE IF NOT EXISTS snippets (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    org_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    title      TEXT NOT NULL DEFAULT '',
    content    TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE snippets ENABLE ROW LEVEL SECURITY;

-- 같은 org 멤버만 조회
CREATE POLICY "snippets_select_same_org" ON snippets
    FOR SELECT USING (
        org_id IN (
            SELECT org_id FROM users WHERE id = auth.uid()
        )
    );

-- 본인만 생성
CREATE POLICY "snippets_insert_own" ON snippets
    FOR INSERT WITH CHECK (
        user_id = auth.uid()
        AND org_id IN (
            SELECT org_id FROM users WHERE id = auth.uid()
        )
    );

-- 본인 스니펫만 수정
CREATE POLICY "snippets_update_own" ON snippets
    FOR UPDATE USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- 본인 스니펫만 삭제
CREATE POLICY "snippets_delete_own" ON snippets
    FOR DELETE USING (user_id = auth.uid());

-- =============================================================
-- 5. invitations
-- =============================================================
CREATE TABLE IF NOT EXISTS invitations (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id      UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    email       TEXT NOT NULL,
    token       TEXT NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(32), 'hex'),
    expires_at  TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '7 days'),
    accepted_at TIMESTAMPTZ
);

ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;

-- admin만 자기 org 초대 생성
CREATE POLICY "invitations_insert_admin" ON invitations
    FOR INSERT WITH CHECK (
        org_id IN (
            SELECT org_id FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- admin만 자기 org 초대 조회
CREATE POLICY "invitations_select_admin" ON invitations
    FOR SELECT USING (
        org_id IN (
            SELECT org_id FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- 초대 수락 시 토큰으로 조회 (anon도 가능하도록)
-- 회원가입 과정에서 토큰 검증 필요
CREATE POLICY "invitations_select_by_token" ON invitations
    FOR SELECT USING (true);

-- 초대 수락 처리 (accepted_at 업데이트)
CREATE POLICY "invitations_update_accept" ON invitations
    FOR UPDATE USING (true)
    WITH CHECK (accepted_at IS NOT NULL);

-- =============================================================
-- 6. Indexes for performance
-- =============================================================
CREATE INDEX IF NOT EXISTS idx_users_org_id ON users(org_id);
CREATE INDEX IF NOT EXISTS idx_memos_org_id ON memos(org_id);
CREATE INDEX IF NOT EXISTS idx_memos_user_id ON memos(user_id);
CREATE INDEX IF NOT EXISTS idx_snippets_org_id ON snippets(org_id);
CREATE INDEX IF NOT EXISTS idx_snippets_user_id ON snippets(user_id);
CREATE INDEX IF NOT EXISTS idx_invitations_org_id ON invitations(org_id);
CREATE INDEX IF NOT EXISTS idx_invitations_token ON invitations(token);
CREATE INDEX IF NOT EXISTS idx_invitations_email ON invitations(email);
