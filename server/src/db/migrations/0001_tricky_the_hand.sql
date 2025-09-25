CREATE TABLE "characters" (
	"id" serial PRIMARY KEY NOT NULL,
	"account_id" integer NOT NULL,
	"x_position" double precision DEFAULT 0 NOT NULL,
	"y_position" double precision DEFAULT 0 NOT NULL,
	"z_position" double precision DEFAULT 0 NOT NULL,
	"name" text NOT NULL,
	"class" integer NOT NULL,
	"level" integer DEFAULT 1 NOT NULL
);
--> statement-breakpoint
ALTER TABLE "characters" ADD CONSTRAINT "characters_account_id_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE no action ON UPDATE no action;