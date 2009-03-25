From: Milan Broz <mbroz@redhat.com>
Date: Wed, 25 Mar 2009 15:30:30 +0100
Subject: [PATCH] lvconvert --repair
In-Reply-To: <87skmkc7q5.fsf@eriador.mornfall.net>
References: <87skn1p0jo.fsf@eriador.mornfall.net>	<498B2A94.7050105@redhat.com>
	<877i3y9od8.fsf@eriador.mornfall.net>
	<87skmkc7q5.fsf@eriador.mornfall.net>
Message-ID: <49CA4006.2010804@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:

> The manpage update is still missing, but all the rest should be addressed in
> the attached patch. (I will chop it up for commit, just sending in all the bits
> together). I'll trow the manpage together later (this should not interfere with
> review or acceptance, I hope).
please try this test - it tries to allocate new log - not sure if it is what we want,
but lvconvert fails but log lv is later visible, vg is still inconsistent
and I am confused what the correct state should be:-)

Milan

diff --git a/test/t-lvconvert-repair.sh b/test/t-lvconvert-repair.sh
index 2b72495..98a5ede 100644
--- a/test/t-lvconvert-repair.sh
+++ b/test/t-lvconvert-repair.sh
@@ -37,3 +37,10 @@ disable_dev $dev3
 lvconvert --repair $vg/mirror
 vgreduce --removemissing $vg
 
+enable_dev $dev3
+vgextend $vg $dev3
+lvcreate -m 2 -l 1 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4
+vgchange -a n $vg
+pvremove -ff -y $dev4
+not echo 'y' | lvconvert --repair $vg/mirror2
+vgs



