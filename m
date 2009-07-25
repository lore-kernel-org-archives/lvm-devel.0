From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:09 -0400
Subject: [PATCH 0/11]: Refactor lvcreate and add lvm_vg_create_lv_linear
Message-ID: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patch set does some refactoring of lvcreate then adds the liblvm
function lvm_vg_create_lv_linear, as well as updates the interactive unit
test to call the API.

I haven't broken the testsuite and applies on top of:
commit 333091a0d31d8f710bac60ab7f6392fe8dcb1c92
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Fri Jul 24 15:15:26 2009 +0000

    Eliminate compile warning introduced by previous commit.



