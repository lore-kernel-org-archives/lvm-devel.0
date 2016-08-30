From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 30 Aug 2016 12:23:50 +0000 (UTC)
Subject: master - config: regenerate
Message-ID: <20160830122350.E7C2860EEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52d1ddd601d278821d69aa35914e0db18f018749
Commit:        52d1ddd601d278821d69aa35914e0db18f018749
Parent:        be85c22f6591435f27380e944f4770612b3b6d3c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 30 13:23:39 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 30 13:23:39 2016 +0100

config: regenerate

---
 conf/example.conf.in |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index b98a19f..b1a2a9c 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -428,6 +428,12 @@ allocation {
 	# 32KiB to 1GiB in multiples of 32.
 	# This configuration option does not have a default value defined.
 
+	# Configuration option allocation/cache_pool_max_chunks.
+	# The maximum number of chunks in a cache pool.
+	# For cache target v1.9 the recommended maximumm is 1000000 chunks.
+	# Using cache pool with more chunks may degrade cache performance.
+	# This configuration option does not have a default value defined.
+
 	# Configuration option allocation/thin_pool_metadata_require_separate_pvs.
 	# Thin pool metdata and data will always use different PVs.
 	thin_pool_metadata_require_separate_pvs = 0
@@ -1684,11 +1690,11 @@ activation {
 	# This configuration option has an automatic default value.
 	# quoted = 1
 
-	# Configuration option report/colums_as_rows.
+	# Configuration option report/columns_as_rows.
 	# Output each column as a row.
 	# If set, this also implies report/prefixes=1.
 	# This configuration option has an automatic default value.
-	# colums_as_rows = 0
+	# columns_as_rows = 0
 
 	# Configuration option report/binary_values_as_numeric.
 	# Use binary values 0 or 1 instead of descriptive literal values.


