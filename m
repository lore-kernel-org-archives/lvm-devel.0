From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 16 Jan 2012 11:38:51 -0500
Subject: Add invalid snapshot awareness to snapshot merge support
In-Reply-To: <20120114025639.GA10541@redhat.com>
References: <20120114025639.GA10541@redhat.com>
Message-ID: <20120116163850.GA28811@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 13 2012 at  9:56pm -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> Prevent an invalid snapshot from being merged via lvconvert.
> Allow an merging snapshot that was invalidated to be removed (useful for
> a snapshot merge that was deferred until next activation but the
> snapshot was invalidated beforehand).

FYI, this patch resolves red hat BZ 761267


