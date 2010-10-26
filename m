From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 26 Oct 2010 11:38:52 +0100
Subject: LVM2/daemons/clvmd clvmd.c
In-Reply-To: <20101026090147.12146.qmail@sourceware.org>
References: <20101026090147.12146.qmail@sourceware.org>
Message-ID: <20101026103852.GC29400@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 09:01:47AM -0000, zkabelac at sourceware.org wrote:
> +		__builtin_unreachable();

Doesn't the analyser respect /* NOTREACHED */ a la lint?

Alasdair


