From: David Teigland <teigland@redhat.com>
Date: Mon, 7 Aug 2017 10:47:39 -0500
Subject: lvmlockd: adopt locks always failed
In-Reply-To: <107b2602-3918-fdbe-6645-da7a2c29e0e9@suse.com>
References: <107b2602-3918-fdbe-6645-da7a2c29e0e9@suse.com>
Message-ID: <20170807154739.GB4875@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> The problem here seems we should not ask sanlock for left lockspaces when
> it's not running?

Yes, thanks for debugging that, I've just pushed a fix.
Dave


