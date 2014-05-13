From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 13 May 2014 09:18:45 +0100
Subject: [PATCH v2] Better clean-up of pvmove failures in a cluster
In-Reply-To: <1399948303.5822.3.camel@f16>
References: <1399948303.5822.3.camel@f16>
Message-ID: <20140513081845.GB17987@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, May 12, 2014 at 09:31:43PM -0500, Jon Brassow wrote:
> Specifically, I'd like to know whether I need to pass a cookie pointer
> and udev_flags.  If I need udev_flags, do I need anything special.
 
That question is the wrong way around:  You should always set those 
parameters exacly like the existing code does unless you have some 
reason why the new code needs to behave differently.

Alasdair


