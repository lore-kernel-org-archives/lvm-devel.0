From: Petr Rockai <prockai@redhat.com>
Date: Mon, 27 Jul 2009 16:47:42 +0200
Subject: crash in dmeventd
In-Reply-To: <Pine.LNX.4.64.0907141942420.6368@hs20-bc2-1.build.redhat.com>
	(Mikulas Patocka's message of "Tue, 14 Jul 2009 20:31:06 -0400 (EDT)")
References: <Pine.LNX.4.64.0907141942420.6368@hs20-bc2-1.build.redhat.com>
Message-ID: <8763de18tt.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mikulas Patocka <mpatocka@redhat.com> writes:
> I got another crash, when attempting to deactivate snapshot, origin and 
> two mirrors at once. It seems like there are multiple bugs in dmeventd and 
> it never worked in upstream code at all, you need to assign it to somebody 
> to fix it.
Is this reproducible? If so, could you please instead send output of:

thread apply all bt full

Thanks!


