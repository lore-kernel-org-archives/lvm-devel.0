From: Lidong Zhong <lzhong@suse.com>
Date: Thu, 25 Sep 2014 10:20:32 +0800
Subject: [PATCH] pvcreate: check the label after writing
Message-ID: <1411611632-2856-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Some device will place metadata area at the beginning part and writing
label may fail.Take our test for example, when running pvcreate on a CDL
formatted DASD device(without partition), it shows successfully create
a pv, but the label is not written on the second sector and pvs shows
nothing. Although it is not supposed to run lvm on dasd device, it's a
friendly behavior to check the label and return error if it fails.

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
 lib/label/label.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/label/label.c b/lib/label/label.c
index ce59da8..4867ede 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -295,6 +295,7 @@ int label_write(struct device *dev, struct label *label)
 {
 	char buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct label_header *lh = (struct label_header *) buf;
+	uint64_t sector;
 	int r = 1;
 
 	if (!label->labeller->ops->write) {
@@ -331,6 +332,9 @@ int label_write(struct device *dev, struct label *label)
 		r = 0;
 	}
 
+	if (!_find_labeller(dev,buf,&sector,0))
+		r = 0;
+
 	if (!dev_close(dev))
 		stack;
 
-- 
1.8.1.4


