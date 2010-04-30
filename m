From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 30 Apr 2010 12:46:47 +0100
Subject: [PATCH 1/3] Display errornous pattern to the user
In-Reply-To: <4BDABF66.1010306@redhat.com>
References: <cover.1272618315.git.zkabelac@redhat.com>
	<faa688b19e8215fa87f2e86d9362e74f15337281.1272618315.git.zkabelac@redhat.com>
	<20100430105509.GC14077@agk-dp.fab.redhat.com>
	<4BDABF66.1010306@redhat.com>
Message-ID: <20100430114647.GF14077@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Apr 30, 2010 at 01:30:46PM +0200, Zdenek Kabelac wrote:
> Well I wanted to make clear what is the expression - which is usually used
> with quotes in lvm.conf. If the user uses spaces inside (or dots for sentence
> end) it might look a bit confusing in the first sight. Thought the user will
> usually immediatelly notice what is wrong - so plain '%s' would do the job as
> well, but I would prefer quotes in this case.
 
Have you tested this?
I'm saying I prefer a message with "a|dev/loop|" to ""a|dev/loop\"".

Alasdair


