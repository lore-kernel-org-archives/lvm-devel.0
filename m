From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2008 20:03:01 -0000
Subject: LVM2/libdm .exported_symbols
Message-ID: <20081103200301.23961.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-03 20:03:01

Modified files:
	libdm          : .exported_symbols 

Log message:
	add list fns

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/libdm/.exported_symbols	2008/04/20 00:11:08	1.33
+++ LVM2/libdm/.exported_symbols	2008/11/03 20:03:00	1.34
@@ -135,3 +135,16 @@
 dm_report_set_output_field_name_prefix
 dm_regex_create
 dm_regex_match
+dm_list_init
+dm_list_add
+dm_list_add_h
+dm_list_del
+dm_list_move
+dm_list_empty
+dm_list_start
+dm_list_end
+dm_list_first
+dm_list_last
+dm_list_prev
+dm_list_next
+dm_list_size


