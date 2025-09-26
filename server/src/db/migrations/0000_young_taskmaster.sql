CREATE TABLE "accounts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"account_name" text NOT NULL,
	"password" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "characters" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"account_id" uuid NOT NULL,
	"x_position" double precision DEFAULT 0 NOT NULL,
	"y_position" double precision DEFAULT 0 NOT NULL,
	"z_position" double precision DEFAULT 0 NOT NULL,
	"name" text NOT NULL,
	"class" integer NOT NULL,
	"level" integer DEFAULT 1 NOT NULL,
	"health" integer NOT NULL,
	"mana" integer NOT NULL,
	"experience" integer NOT NULL
);
--> statement-breakpoint
ALTER TABLE "characters" ADD CONSTRAINT "characters_account_id_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE no action ON UPDATE no action;