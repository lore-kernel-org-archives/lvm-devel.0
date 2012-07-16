From: dongsu.park@profitbricks.com <dongsu.park@profitbricks.com>
Date: Mon, 16 Jul 2012 23:18:37 +0200
Subject: [RFC PATCH 1/3] lvm-wrappers: implement wrappers to get min/max u64 values
In-Reply-To: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
References: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
Message-ID: <1342473519-2853-2-git-send-email-dongsu.park@profitbricks.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Dongsu Park <dongsu.park@profitbricks.com>

Simple wrappers to get minimum or maximum values from the two uint64 values.

Signed-off-by: Dongsu Park <dongsu.park@profitbricks.com>
---
 lib/misc/lvm-wrappers.c |   10 ++++++++++
 lib/misc/lvm-wrappers.h |    3 +++
 2 files changed, 13 insertions(+)

diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index 6cffae3..8906642 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -117,3 +117,13 @@ int read_urandom(void *buf, size_t len)
 	return 1;
 }
 
+uint64_t get_max_val_u64(uint64_t val1, uint64_t val2)
+{
+	return (val1 > val2) ? val1 : val2;
+}
+
+uint64_t get_min_val_u64(uint64_t val1, uint64_t val2)
+{
+	return (val1 < val2) ? val1 : val2;
+}
+
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index e43f831..335e282 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -32,6 +32,9 @@ int lvm_getpagesize(void);
  */
 int read_urandom(void *buf, size_t len);
 
+uint64_t get_max_val_u64(uint64_t val1, uint64_t val2);
+uint64_t get_min_val_u64(uint64_t val1, uint64_t val2);
+
 #  ifndef HAVE_SIGINTERRUPT
 #    define siginterrupt(sig, flag) \
 	do { \
-- 
1.7.10


