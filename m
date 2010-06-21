From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 21 Jun 2010 16:13:28 +0100
Subject: LVM2 ./WHATS_NEW tools/reporter.c
In-Reply-To: <20100617131553.18299.qmail@sourceware.org>
References: <20100617131553.18299.qmail@sourceware.org>
Message-ID: <20100621151328.GB26395@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jun 17, 2010 at 01:15:53PM -0000, mbroz at sourceware.org wrote:
> 	Fix exit code when requesting help using documented -o help option.

Fix is incomplete.

For example:
> lvs -o +help
still gives me exit status 5.

Alasdair


