From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 28 Sep 2009 13:15:19 +0100
Subject: [PATCH 1/3] use display_size function instead of hardcoding
In-Reply-To: <1253979227-28051-1-git-send-email-impulze@impulze.org>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
Message-ID: <20090928121519.GC5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Sep 26, 2009 at 05:33:45PM +0200, Daniel Mierswa wrote:
> We should use display_size everywhere for consistency reasons. Other
> commands and places that print the stripe/PE size already do that.
> This might break scripts that rely on the stripe/PE size being printed
> in KByte in those circumstances.

I can't make this change in RHEL5 and since we use the upstream code base
that means we need to make it conditional, probably with an lvm.conf setting
with a default value chosen at configuration time.

Alasdair


