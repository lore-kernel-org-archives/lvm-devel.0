From: Dave Wysochanski <wysochanski@pobox.com>
Date: Mon, 22 Nov 2010 22:07:46 -0500
Subject: [PATCH 3/3] Update tests for lvseg properties 'devices' and 'seg_pe_ranges'.
In-Reply-To: <1290481666-11149-1-git-send-email-wysochanski@pobox.com>
References: <1290481666-11149-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290481666-11149-4-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add display of 'devices' and 'seg_pe_ranges' in interactive test.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 test/api/test.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index f19268f..0484ad7 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -793,6 +793,10 @@ static void _lvsegs_in_lv(char **argv, int argc)
 		_print_property_value("seg_start_pe", v);
 		v = lvm_lvseg_get_property(lvl->lvseg, "seg_size");
 		_print_property_value("seg_size", v);
+		v = lvm_lvseg_get_property(lvl->lvseg, "devices");
+		_print_property_value("devices", v);
+		v = lvm_lvseg_get_property(lvl->lvseg, "seg_pe_ranges");
+		_print_property_value("seg_pe_ranges", v);
 	}
 }
 
-- 
1.7.2.2


