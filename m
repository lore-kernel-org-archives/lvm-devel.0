From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 09 Aug 2007 13:55:05 -0400
Subject: [LVM2 PATCH] (3/3) Add metadata validation for snapshot
Message-ID: <46BB54F9.7070702@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Additional validation check for snapshot LV.
This one is enough to prevent 'cow == origin' snapshot.

Currently, a snapshot whose origin and cow are same is
silently accepted.
Example of corrupted metadata:
                snapshot0 {
                        id = "R0o4p6-DDyy-O2td-RQDJ-dRP7-24zy-90VzgR"
                        status = ["READ", "WRITE", "VISIBLE"]
                        segment_count = 1

                        segment1 {
                                start_extent = 0
                                extent_count = 1        # 4 Megabytes

                                type = "snapshot"
                                chunk_size = 16
                                origin = "lvol0"
                                cow_store = "lvol0"
                        }
                }

With this patch, we'll get a following message for such metadata:
  LV snapshot0: segment 1 has a LV lvol0 for both snapshot origin and cow store
  Internal error: LV segments corrupted in snapshot0.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-validate-snapshot.patch
Type: text/x-patch
Size: 741 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/280f524c/attachment.bin>
