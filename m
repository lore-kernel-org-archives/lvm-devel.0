From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 25 Aug 2015 17:54:38 +0000 (UTC)
Subject: master - makefiles: fix ld version script generation for older make versions
Message-ID: <20150825175438.0450860D28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19ef3e0f31f375be72da875a5e6beb5d10af44df
Commit:        19ef3e0f31f375be72da875a5e6beb5d10af44df
Parent:        463f59eca4330300c549b40603065b8640fdb790
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Aug 25 18:18:34 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Aug 25 18:51:57 2015 +0100

makefiles: fix ld version script generation for older make versions

Commit 82a27a8 introduced a change to the symbol versioning macros
that allows a new version of a function to be introduced while
keeping the old behaviour via a versioned symbol export. The new
symbol is listed in the current .exported_symbols.DM_* file and a
default (@@VERSION) binding is created during linking.

This broke the build on RHEL5, RHEL6 and Debian Lenny. This is
because the make version in these distros returns results from the
$(wildcard *) command in a different order to the RHEL7 and F22
versions: this affects the ordering of the generated .export.sym
version script:

RHEL7/F22
for i in ./.exported_symbols.Base ./.exported_symbols.DM_1_02_99
 ./.exported_symbols.DM_1_02_98 ./.exported_symbols.DM_1_02_97
 ./.exported_symbols.DM_1_02_106 ./.exported_symbols.DM_1_02_105
 ./.exported_symbols.DM_1_02_103 ./.exported_symbols.DM_1_02_101
 ./.exported_symbols.DM_1_02_104 ./.exported_symbols.DM_1_02_100

 290: 000000000003d101   106 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region_v1_02_104
*388: 000000000003cfc7   314 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region@@DM_1_02_106
 391: 000000000003d101   106 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region at DM_1_02_104
*552: 000000000003cfc7   314 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region
 944: 000000000003d101   106 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region_v1_02_104
 992: 000000000003d101   106 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region at DM_1_02_104

RHEL6:
for i in ./.exported_symbols.Base ./.exported_symbols.DM_1_02_100
 ./.exported_symbols.DM_1_02_101 ./.exported_symbols.DM_1_02_103
 ./.exported_symbols.DM_1_02_104 ./.exported_symbols.DM_1_02_105
 ./.exported_symbols.DM_1_02_106 ./.exported_symbols.DM_1_02_97
 ./.exported_symbols.DM_1_02_98 ./.exported_symbols.DM_1_02_99; do\

 290: 000000000003d0e1   106 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region_v1_02_104
 390: 000000000003d0e1   106 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region at DM_1_02_104
*479: 000000000003cfa7   314 FUNC    LOCAL  DEFAULT   12 dm_stats_create_region
 944: 000000000003d0e1   106 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region_v1_02_104
 992: 000000000003d0e1   106 FUNC    GLOBAL DEFAULT   12 dm_stats_create_region at DM_1_02_104

The F22 build has the correct behaviour (although the sort order is
inconsistent) but on RHEL6 the 1_02_106 symbol file appears after
version 1_02_104 which introduced the original symbol. This causes
the later version of the symbol to lose its version binding and be
reduced to local scope.

If using un-versioned exports of the current version of a symbol
(i.e.  exported with the plain symbol name and no macro) and using
the linker script to set the symbol version, the current version
node must appear first in the version script: the un-versioned
symbol will be bound to the first version node found that contains
it.

On RHEL6 and the other older distros the original version of the
dm_stats_create_region() call sorted before the current version
(DM_1_02_104 vs. DM_1_02_106) leading to a subsequent link error for
the later symbol version:

dmsetup.o: In function `_do_stats_create_regions':
/root/src/git/lvm2/tools/dmsetup.c:4658: undefined reference to
`dm_stats_create_region'

Ensure that the ordering of entries in the version script is
consistent to avoid an old implementation shadowing a newer one by
sorting the list of file names before the loop:

  $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | sort -rnt_ -k5 )

This only sorts by patch level but this is sufficient to maintain
the correct order for current version files.

Tested on RHEL5, 6, 7 and F22.
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index e4f8835..3e39a3a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -502,7 +502,7 @@ else
 	set -e;\
 	R=$$(sort $^ | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
-	for i in $(EXPORTED_SYMBOLS); do\
+	for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | sort -rnt_ -k5 )); do\
 		echo "$${i##*.} {"; echo "	global:";\
 		$(SED) "s/^/		/;s/$$/;/" $$i;\
 		test "$$i" = Base && { echo "	local:"; echo "		*;"; };\


