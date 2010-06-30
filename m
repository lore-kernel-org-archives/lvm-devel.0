From: Milan Broz <mbroz@redhat.com>
Date: Wed, 30 Jun 2010 14:44:22 +0200
Subject: [PATCH] Fix vgremove to allow removal of VG with missing PVs.
In-Reply-To: <87mxuclmre.fsf@twilight.int.mornfall.net.>
References: <1277897478-15448-1-git-send-email-mbroz@redhat.com>
	<87mxuclmre.fsf@twilight.int.mornfall.net.>
Message-ID: <4C2B3C26.7080909@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On 06/30/2010 02:37 PM, Petr Rockai wrote:
> Looks OK as far as I can tell. Maybe just add "not vgremove $vg" just
> before "vgremove -f $vg" in the test.

then it asks interactively because -f is overloaded here to disable
lv removal question also:-)

There should be -y added, but it is for another patch probably.

Milan


