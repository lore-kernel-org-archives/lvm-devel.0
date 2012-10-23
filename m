From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 23 Oct 2012 19:55:14 +0000 (UTC)
Subject: master - python-lvm: seg. fault in liblvm_lvm_percent_to_float
Message-ID: <20121023195514.C0310242D@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8073ce16900def5a200fce44cb69862bfc50d4ce
Commit:        8073ce16900def5a200fce44cb69862bfc50d4ce
Parent:        a820a68619c10108666f8093545837233c954046
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 23 14:50:14 2012 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Oct 23 14:54:06 2012 -0500

python-lvm: seg. fault in liblvm_lvm_percent_to_float

The first parameter needs to be present even if it isn't being
used, otherwise the one any only parameter we get is null
which causes PyArg_ParseTuple to seg. fault.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 024d769..4da2999 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -153,7 +153,7 @@ liblvm_lvm_list_vg_uuids(void)
 }
 
 static PyObject *
-liblvm_lvm_percent_to_float(PyObject *arg)
+liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
 {
 	double converted;
 	int percent;


