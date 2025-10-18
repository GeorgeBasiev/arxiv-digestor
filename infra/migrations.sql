CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS papers (
  id BIGSERIAL PRIMARY KEY,
  source TEXT NOT NULL DEFAULT 'arxiv',
  source_id TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  abstract TEXT,
  url TEXT,
  primary_category TEXT,
  published_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chunks (
  id BIGSERIAL PRIMARY KEY,
  paper_id BIGINT REFERENCES papers(id) ON DELETE CASCADE,
  chunk_ix INT NOT NULL,
  text TEXT NOT NULL,
  embedding VECTOR(4096),             
  token_count INT,
  UNIQUE(paper_id, chunk_ix)
);

CREATE INDEX IF NOT EXISTS idx_papers_published_at ON papers(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_chunks_paper ON chunks(paper_id);
CREATE INDEX IF NOT EXISTS idx_chunks_embedding ON chunks USING ivfflat (embedding vector_cosine) WITH (lists = 100);

CREATE TABLE IF NOT EXISTS summaries (
  id BIGSERIAL PRIMARY KEY,
  paper_id BIGINT REFERENCES papers(id) ON DELETE CASCADE,
  kind TEXT CHECK (kind IN ('short','long','bullets','faq')),
  text TEXT NOT NULL,
  model TEXT,
  prompt_version TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS evaluations (
  id BIGSERIAL PRIMARY KEY,
  paper_id BIGINT REFERENCES papers(id) ON DELETE CASCADE,
  metric TEXT,
  value DOUBLE PRECISION,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);
