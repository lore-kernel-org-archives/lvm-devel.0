From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Feb 2017 21:55:20 +0000 (UTC)
Subject: master - coverity cleanups
Message-ID: <20170214215520.60A99610FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2c5bb5c7066142930c88275d2fb6c8552559c9a
Commit:        d2c5bb5c7066142930c88275d2fb6c8552559c9a
Parent:        1236e0ed293d13bff1205dbd2ac31877278b7a90
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 14 15:53:29 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 14 15:53:29 2017 -0600

coverity cleanups

---
 tools/command.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/command.h b/tools/command.h
index 3d708f0..0c3f9f3 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -69,7 +69,7 @@ struct command_name {
 
 static inline int val_bit_is_set(uint64_t val_bits, int val_enum)
 {
-	return (val_bits & (1 << val_enum)) ? 1 : 0;
+	return (val_bits & (1ULL << val_enum)) ? 1 : 0;
 }
 
 static inline uint64_t val_enum_to_bit(int val_enum)
@@ -79,7 +79,7 @@ static inline uint64_t val_enum_to_bit(int val_enum)
 
 static inline int lvp_bit_is_set(uint64_t lvp_bits, int lvp_enum)
 {
-	return (lvp_bits & (1 << lvp_enum)) ? 1 : 0;
+	return (lvp_bits & (1ULL << lvp_enum)) ? 1 : 0;
 }
 
 static inline uint64_t lvp_enum_to_bit(int lvp_enum)
@@ -89,7 +89,7 @@ static inline uint64_t lvp_enum_to_bit(int lvp_enum)
 
 static inline int lvt_bit_is_set(uint64_t lvt_bits, int lvt_enum)
 {
-	return (lvt_bits & (1 << lvt_enum)) ? 1 : 0;
+	return (lvt_bits & (1ULL << lvt_enum)) ? 1 : 0;
 }
 
 static inline uint64_t lvt_enum_to_bit(int lvt_enum)


