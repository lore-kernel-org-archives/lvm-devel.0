From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 26 Jul 2009 15:13:02 -0400
Subject: [PATCH 0/4] Implement activation related liblvm APIs.
Message-ID: <1248635586-8139-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patch set implements lvm_lv_activate, lvm_lv_deactivate,
lvm_lv_is_suspended and lvm_lv_is_active.

Applies cleanly on:
commit ac1f36ae761cb803250042fefcfd1ec5148ff659
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Sun Jul 26 16:49:52 2009 +0000

    A few more lvm.h updates that got missed.
    


