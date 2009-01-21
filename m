From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:56 +0100
Subject: [PATCH 15/15] Add simple test for crypto volumes.
In-Reply-To: <900e6948cfd4c8cacb60ea896cb8ffcbe1bf5d7b.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
	<3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
	<6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
	<0cf2e4e850e1c919e0e6bc98504be6d5087caa1c.1232488181.git.mbroz@redhat.com>
	<b8d375b5ca799bd88ff701ba19b93bed02f62343.1232488181.git.mbroz@redhat.com>
	<3d899235af519a0e471dc86df580a991371b91fd.1232488181.git.mbroz@redhat.com>
	<35fcbf3ab1527b121e3a8064a35eab8f7a7a2f1d.1232488181.git.mbroz@redhat.com>
	<11624519b513cc630635406dc8b35f380bb43a9f.1232488181.git.mbroz@redhat.com>
	<8063c7b937ce3760c31028df5e6689d2bb35fde1.1232488181.git.mbroz@redhat.com>
	<56eb4722a65edf5a12d79098ab2ec848b3e727b4.1232488181.git.mbroz@redhat.com>
	<900e6948cfd4c8cacb60ea896cb8ffcbe1bf5d7b.1232488181.git.mbroz@redhat.com>
Message-ID: <412871f8e022bd3f6a1833b3dbdb418cd2150c25.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 test/t-crypto-usage.sh |   54 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)
 create mode 100755 test/t-crypto-usage.sh

diff --git a/test/t-crypto-usage.sh b/test/t-crypto-usage.sh
new file mode 100755
index 0000000..2462931
--- /dev/null
+++ b/test/t-crypto-usage.sh
@@ -0,0 +1,54 @@
+#!/bin/sh
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Exercise some encrypted volumes operations'
+
+. ./test-utils.sh
+
+aux prepare_pvs 2
+aux pvcreate $devs
+vgcreate -cn $vg $devs -s 4M
+
+cipher="aes-cbc-essiv:sha256"
+key_plain="0123456789012345678901234567890101234567890123456789012345678901"
+keysize=256
+password="xxx"
+
+modprobe dm_crypt
+
+# 'lvcreate creates simple encrypted volume'
+echo $key_plain | lvcreate -n $lv1 -l 4 --crypt plain --cipher $cipher --keysize $keysize --keyfile - $vg
+echo $key_plain | lvcreate -n $lv2 -l 4 --crypt $vg/$lv1 --keyfile - $vg
+
+# 'deactivate volumes'
+lvchange -a n $vg/$lv1
+lvchange -a n $vg/$lv2
+echo $key_plain | vgchange -a y --keyfile -
+
+# 'cannot remove used cryptostore directly
+not lvremove $vg/cryptostore0
+
+# 'resize active volume'
+lvresize -l 8 $vg/$lv1
+lvresize -f -l 4 $vg/$lv1
+
+# 'lvremove removes simple encrypted volume'
+lvremove -ff $vg/$lv1
+lvremove -ff $vg/$lv2
+
+# 'import luks volume, using first extent as keystore (extent is 8192 sectors)'
+lvcreate -n $lv3 -L 36M $vg
+echo -n $password | cryptsetup luksFormat -q $G_dev_/$vg/$lv3 --key-size $keysize --align-payload=8192 --key-file -
+lvconvert --crypt luks1 $vg/$lv3
+echo $password | lvchange -a y $vg/$lv3 --keyfile -
+lvchange -a n $vg/$lv3
+lvremove -ff $vg/$lv3
+
-- 
1.5.6.5


