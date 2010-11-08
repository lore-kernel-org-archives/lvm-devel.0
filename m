From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 8 Nov 2010 18:37:16 +0000
Subject: LVM2/daemons/clvmd clvmd.c
In-Reply-To: <20101026095704.18295.qmail@sourceware.org>
References: <20101026095704.18295.qmail@sourceware.org>
Message-ID: <20101108183716.GI15253@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 09:57:04AM -0000, zkabelac at sourceware.org wrote:
> 	Hotfix usage of __builtin_unreachable()

Changing this for the current release: removing the ugly ifdef and
using an __attribute__((noreturn)) function instead.

Alasdair


