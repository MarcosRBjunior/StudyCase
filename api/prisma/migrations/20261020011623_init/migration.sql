-- CreateEnum
CREATE TYPE "tech_category" AS ENUM ('FRONTEND', 'BACKEND', 'DATABASE', 'INFRA', 'TOOLING', 'OTHER');

-- CreateEnum
CREATE TYPE "case_study_section_kind" AS ENUM ('CONTEXT', 'PROCESS', 'DECISION', 'CHALLENGE', 'RESULT', 'LEARNING', 'OTHER');

-- CreateTable
CREATE TABLE "projects" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "slug" VARCHAR(80) NOT NULL,
    "title" JSONB NOT NULL,
    "summary" JSONB,
    "description" JSONB NOT NULL,
    "repository_url" VARCHAR(500),
    "live_url" VARCHAR(500),
    "started_on" DATE,
    "finished_on" DATE,
    "display_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_features" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "project_id" UUID NOT NULL,
    "title" JSONB NOT NULL,
    "description" JSONB,
    "position" SMALLINT NOT NULL,

    CONSTRAINT "project_features_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "technologies" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(60) NOT NULL,
    "slug" VARCHAR(60) NOT NULL,
    "category" "tech_category",
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "technologies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_technologies" (
    "project_id" UUID NOT NULL,
    "technology_id" UUID NOT NULL,
    "how_used" JSONB NOT NULL,
    "position" SMALLINT NOT NULL,

    CONSTRAINT "project_technologies_pkey" PRIMARY KEY ("project_id","technology_id")
);

-- CreateTable
CREATE TABLE "project_images" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "project_id" UUID NOT NULL,
    "url" VARCHAR(1000) NOT NULL,
    "provider_public_id" VARCHAR(255) NOT NULL,
    "alt_text" JSONB NOT NULL,
    "caption" JSONB,
    "width" INTEGER,
    "height" INTEGER,
    "is_cover" BOOLEAN NOT NULL DEFAULT false,
    "position" SMALLINT NOT NULL,

    CONSTRAINT "project_images_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "case_studies" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "project_id" UUID NOT NULL,
    "summary" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "case_studies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "case_study_sections" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "case_study_id" UUID NOT NULL,
    "kind" "case_study_section_kind" NOT NULL,
    "title" JSONB NOT NULL,
    "body" JSONB NOT NULL,
    "position" SMALLINT NOT NULL,

    CONSTRAINT "case_study_sections_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "projects_slug_key" ON "projects"("slug");

-- CreateIndex
CREATE INDEX "projects_listing_idx" ON "projects"("display_order", "created_at" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "project_features_project_id_position_key" ON "project_features"("project_id", "position");

-- CreateIndex
CREATE UNIQUE INDEX "technologies_slug_key" ON "technologies"("slug");

-- CreateIndex
CREATE INDEX "project_technologies_technology_idx" ON "project_technologies"("technology_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_technologies_project_id_position_key" ON "project_technologies"("project_id", "position");

-- CreateIndex
CREATE UNIQUE INDEX "project_images_project_id_position_key" ON "project_images"("project_id", "position");

-- CreateIndex
CREATE UNIQUE INDEX "case_studies_project_id_key" ON "case_studies"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "case_study_sections_case_study_id_position_key" ON "case_study_sections"("case_study_id", "position");

-- AddForeignKey
ALTER TABLE "project_features" ADD CONSTRAINT "project_features_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_technologies" ADD CONSTRAINT "project_technologies_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_technologies" ADD CONSTRAINT "project_technologies_technology_id_fkey" FOREIGN KEY ("technology_id") REFERENCES "technologies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_images" ADD CONSTRAINT "project_images_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "case_studies" ADD CONSTRAINT "case_studies_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "case_study_sections" ADD CONSTRAINT "case_study_sections_case_study_id_fkey" FOREIGN KEY ("case_study_id") REFERENCES "case_studies"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ---------------------------------------------------------------------------
-- Acrescentado à mão (o Prisma não expressa estas regras no schema).
-- Seção 11 da especificação: is_localized, CHECKs, índice parcial de capa e RLS.
-- ---------------------------------------------------------------------------

-- LocalizedText (RN-14): exatamente as chaves pt-BR e en, ambas texto,
-- com tamanho entre min_len e max_len em cada idioma.
CREATE FUNCTION is_localized(value jsonb, min_len int, max_len int)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $$
  SELECT COALESCE(CASE
    WHEN jsonb_typeof(value) <> 'object' THEN false
    ELSE (SELECT count(*) FROM jsonb_object_keys(value)) = 2
     AND jsonb_typeof(value -> 'pt-BR') = 'string'
     AND jsonb_typeof(value -> 'en') = 'string'
     AND char_length(value ->> 'pt-BR') BETWEEN min_len AND max_len
     AND char_length(value ->> 'en') BETWEEN min_len AND max_len
  END, false)
$$;

-- projects
ALTER TABLE "projects"
  ADD CONSTRAINT "projects_slug_format_check" CHECK ("slug" ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  ADD CONSTRAINT "projects_title_check" CHECK (is_localized("title", 3, 120)),
  ADD CONSTRAINT "projects_summary_check" CHECK ("summary" IS NULL OR is_localized("summary", 1, 280)),
  ADD CONSTRAINT "projects_description_check" CHECK (is_localized("description", 10, 5000)),
  ADD CONSTRAINT "projects_display_order_check" CHECK ("display_order" >= 0),
  ADD CONSTRAINT "projects_dates_check" CHECK ("finished_on" IS NULL OR "started_on" IS NULL OR "finished_on" >= "started_on");

-- project_features
ALTER TABLE "project_features"
  ADD CONSTRAINT "project_features_title_check" CHECK (is_localized("title", 1, 120)),
  ADD CONSTRAINT "project_features_description_check" CHECK ("description" IS NULL OR is_localized("description", 1, 500)),
  ADD CONSTRAINT "project_features_position_check" CHECK ("position" >= 0);

-- technologies
ALTER TABLE "technologies"
  ADD CONSTRAINT "technologies_slug_format_check" CHECK ("slug" ~ '^[a-z0-9]+(-[a-z0-9]+)*$');

-- project_technologies
ALTER TABLE "project_technologies"
  ADD CONSTRAINT "project_technologies_how_used_check" CHECK (is_localized("how_used", 3, 1000)),
  ADD CONSTRAINT "project_technologies_position_check" CHECK ("position" >= 0);

-- project_images
ALTER TABLE "project_images"
  ADD CONSTRAINT "project_images_alt_text_check" CHECK (is_localized("alt_text", 3, 200)),
  ADD CONSTRAINT "project_images_caption_check" CHECK ("caption" IS NULL OR is_localized("caption", 1, 300)),
  ADD CONSTRAINT "project_images_width_check" CHECK ("width" > 0),
  ADD CONSTRAINT "project_images_height_check" CHECK ("height" > 0),
  ADD CONSTRAINT "project_images_position_check" CHECK ("position" >= 0);

-- RN-05: no máximo uma capa por projeto.
CREATE UNIQUE INDEX "project_images_one_cover_idx" ON "project_images" ("project_id") WHERE "is_cover";

-- case_studies
ALTER TABLE "case_studies"
  ADD CONSTRAINT "case_studies_summary_check" CHECK ("summary" IS NULL OR is_localized("summary", 1, 2000));

-- case_study_sections
ALTER TABLE "case_study_sections"
  ADD CONSTRAINT "case_study_sections_title_check" CHECK (is_localized("title", 1, 120)),
  ADD CONSTRAINT "case_study_sections_body_check" CHECK (is_localized("body", 10, 20000)),
  ADD CONSTRAINT "case_study_sections_position_check" CHECK ("position" >= 0);

-- Supabase: fecha a Data API mesmo que ela seja religada. O Prisma conecta como dono
-- das tabelas e não é afetado. Funciona também no Postgres local.
ALTER TABLE "projects"             ENABLE ROW LEVEL SECURITY;
ALTER TABLE "project_features"     ENABLE ROW LEVEL SECURITY;
ALTER TABLE "technologies"         ENABLE ROW LEVEL SECURITY;
ALTER TABLE "project_technologies" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "project_images"       ENABLE ROW LEVEL SECURITY;
ALTER TABLE "case_studies"         ENABLE ROW LEVEL SECURITY;
ALTER TABLE "case_study_sections"  ENABLE ROW LEVEL SECURITY;
