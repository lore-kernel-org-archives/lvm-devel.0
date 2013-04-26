From: Andy Grover <agrover@redhat.com>
Date: Thu, 25 Apr 2013 17:11:57 -0700
Subject: [PATCH 1/2] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <5179B8DB.2010805@redhat.com>
References: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
	<1360689876-13552-2-git-send-email-mohan@in.ibm.com>
	<512BBF6B.3060004@redhat.com> <87wqtsznrx.fsf@in.ibm.com>
	<512F7928.80209@redhat.com> <512FBF12.30803@redhat.com>
	<512FD2B8.5030009@redhat.com> <5179B8DB.2010805@redhat.com>
Message-ID: <5179C64D.5010000@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/25/2013 04:14 PM, Tony Asleson wrote:

> At the moment I've kind of exhausted everything I can think of.  Does
> anyone else have any ideas that would lend itself to an API that can
> accommodate a plethora of configurable options, allow a sane default for
> common uses cases and not create any potential opportunities for
> incorrect use?

I just want an API so I can create thinp LVs from a pool from scratch, 
and create thinp LVs based on another thinp LV.

I don't care about options. Use the defaults. Let's get something going 
and then iterate.

-- Andy


