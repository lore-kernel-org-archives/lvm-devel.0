From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Mar 2017 12:06:53 -0400
Subject: master - man: remove blank lines
Message-ID: <201703151606.v2FG6rHW012284@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e9bc7786538663f0079709f861d4deb873baaa2
Commit:        7e9bc7786538663f0079709f861d4deb873baaa2
Parent:        f536c53aee3e64495ab71d625426f4f965713e77
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 15 11:05:31 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 15 11:05:31 2017 -0500

man: remove blank lines

Blank lines in the man source sometimes appear as extra
blank lines in the output, so remove them.
---
 man/lvcreate.8_des |    2 --
 man/vgs.8_end      |    1 -
 tools/command.c    |   42 ++++++++++++++++--------------------------
 3 files changed, 16 insertions(+), 29 deletions(-)

diff --git a/man/lvcreate.8_des b/man/lvcreate.8_des
index acc07b3..2f5c5c1 100644
--- a/man/lvcreate.8_des
+++ b/man/lvcreate.8_des
@@ -27,7 +27,6 @@ a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
 
 .SS Usage notes
-
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
@@ -36,4 +35,3 @@ In the usage section below, \fB--name\fP is omitted from the required
 options, even though it is typically used.  When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.  Also see the description in the options section.
-
diff --git a/man/vgs.8_end b/man/vgs.8_end
index b8cda26..09ece2b 100644
--- a/man/vgs.8_end
+++ b/man/vgs.8_end
@@ -14,4 +14,3 @@ are missing from the system
 Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
 .IP 6 3
 (c)lustered, (s)hared
-
diff --git a/tools/command.c b/tools/command.c
index 0abc309..514a71c 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1869,7 +1869,6 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 	if (!desc_first && cmd->desc)
 		_print_usage_description(cmd);
 
-	printf("\n");
 	return;
 }
 
@@ -1916,7 +1915,7 @@ void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 		printf(" ]");
 	}
 
-	printf("\n\n");
+	printf("\n");
 }
 
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
@@ -1989,7 +1988,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 		printf(" ]");
 	}
 
-	printf("\n\n");
+	printf("\n");
 }
 
 void print_usage_notes(struct command_name *cname)
@@ -2567,7 +2566,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
  op_count:
 	if (!cmd->op_count)
-		goto done;
+		return;
 
 	printf(".RS 4\n");
 	printf("[");
@@ -2583,9 +2582,6 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 	printf(" ]\n");
 	printf(".RE\n");
-
- done:
-	printf("\n");
 }
 
 /*
@@ -2688,7 +2684,7 @@ void print_man_usage_common_lvm(struct command *cmd)
 		}
 	}
 
-	printf("\n.RE\n");
+	printf(".RE\n");
 	return;
 }
 
@@ -2792,8 +2788,7 @@ void print_man_usage_common_cmd(struct command *cmd)
 		}
 	}
 
-	printf("\n.RE\n");
-	printf(".br\n");
+	printf(".RE\n");
 	printf("\n");
 	return;
 }
@@ -2943,7 +2938,7 @@ void print_man_all_options_desc(struct command_name *cname)
 		if (!cname->all_options[opt_enum])
 			continue;
 
-		printf("\n.HP\n");
+		printf(".HP\n");
 
 		printf(".ad l\n");
 
@@ -3043,7 +3038,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_vg_val) {
-		printf("\n.HP\n");
+		printf(".HP\n");
 
 		printf("\\fI%s\\fP", val_names[vg_VAL].name);
 		printf("\n");
@@ -3057,7 +3052,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_lv_val) {
-		printf("\n.HP\n");
+		printf(".HP\n");
 
 		printf("\\fI%s\\fP", val_names[lv_VAL].name);
 		printf("\n");
@@ -3071,7 +3066,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_pv_val) {
-		printf("\n.HP\n");
+		printf(".HP\n");
 
 		printf("\\fI%s\\fP", val_names[pv_VAL].name);
 		printf("\n");
@@ -3086,7 +3081,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_tag_val) {
-		printf("\n.HP\n");
+		printf(".HP\n");
 
 		printf("\\fI%s\\fP", val_names[tag_VAL].name);
 		printf("\n");
@@ -3096,7 +3091,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_select_val) {
-		printf("\n.HP\n");
+		printf(".HP\n");
 
 		printf("\\fI%s\\fP", val_names[select_VAL].name);
 		printf("\n");
@@ -3108,7 +3103,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 
 	/* Every command uses a string arg somewhere. */
 
-	printf("\n.HP\n");
+	printf(".HP\n");
 	printf("\\fI%s\\fP", val_names[string_VAL].name);
 	printf("\n");
 	printf(".br\n");
@@ -3120,7 +3115,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	 * so common that we should probably always print it.
 	 */
 
-	printf("\n.HP\n");
+	printf(".HP\n");
 	printf("\\fISize\\fP[UNIT]");
 	printf("\n");
 	printf(".br\n");
@@ -3210,7 +3205,7 @@ static void include_description_file(char *name, char *des_file)
 	buf[MAX_MAN_DESC-1] = '\0';
 
 	printf(".SH DESCRIPTION\n");
-	printf("%s\n", buf);
+	printf("%s", buf);
 
 	close(fd);
 }
@@ -3240,11 +3235,9 @@ void print_man(char *name, char *des_file, int secondary)
 			print_man_usage_common_cmd(prev_cmd);
 			print_man_usage_common_lvm(prev_cmd);
 
-			printf("\n");
 			printf(".SH OPTIONS\n");
 			print_man_all_options_desc(cname);
 			printf(".SH VARIABLES\n");
-			printf(".br\n");
 			print_man_all_positions_desc(cname);
 
 			prev_cmd = NULL;
@@ -3294,13 +3287,10 @@ void print_man(char *name, char *des_file, int secondary)
 				printf(".br\n");
 			}
 
-			printf("\n");
-
 			/* listing them all when there's only 1 or 2 is just repetative */
 			if (cname->variants > 2) {
 				printf(".P\n");
 				print_man_all_options_list(cname);
-				printf("\n");
 			}
 
 			if (des_file) {
@@ -3328,7 +3318,7 @@ void print_man(char *name, char *des_file, int secondary)
 			print_man_all_positions_desc(cname);
 		} else {
 			if (cname->variants > 2)
-				printf("--\n");
+				printf("-\n");
 		}
 
 		printf("\n");
@@ -3375,7 +3365,7 @@ void print_man_secondary(char *name)
 
 		print_man_usage(lvmname, cmd);
 
-		printf("--\n");
+		printf("-\n");
 		printf("\n");
 	}
 }


