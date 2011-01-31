From: Petr Rockai <prockai@redhat.com>
Date: Mon, 31 Jan 2011 11:33:04 +0100
Subject: [PATCH 11/24] Perf: New HASH function
In-Reply-To: <218d7b05db3253b968962a886cf3797f6d423b10.1296391340.git.zkabelac@redhat.com>
	(Zdenek Kabelac's message of "Sun, 30 Jan 2011 13:57:34 +0100")
References: <cover.1296391340.git.zkabelac@redhat.com>
	<cover.1296391340.git.zkabelac@redhat.com>
	<218d7b05db3253b968962a886cf3797f6d423b10.1296391340.git.zkabelac@redhat.com>
Message-ID: <87fws9nz1b.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> Providing 2 new hash function for selection.

My experience is that Bob Jenkins's LOOKUP3 is the best available hash
by far, for use in tables. It's not very complicated and comes with
well-optimised C implementation. Shows both excellent distribution and
speed.

Yours,
   Petr


