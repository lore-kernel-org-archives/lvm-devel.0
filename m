From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Oct 2009 00:57:09 +0100
Subject: [PATCH 10/11] debian: make the subdir recursion -j capable
In-Reply-To: <14be282c1124b6bcb3652593127d3878707585fc.1255002311.git.fdinitto@redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<14be282c1124b6bcb3652593127d3878707585fc.1255002311.git.fdinitto@redhat.com>
Message-ID: <20091008235709.GX3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 08, 2009 at 02:49:17PM +0200, Fabio M. Di Nitto wrote:
> but it removes some dependencies on the way
 
The tree isn't constructed for a basic recursion mechanism to work
properly at the moment, and the inter-dependencies all play a role in
coping with whatever configuration and make targets are thrown at it.
(Nor does the current setup work perfectly today.)

So let's park this one for now, then include the possibility of moving
some files/directories/targets around so a simple recursion mechanism
could perhaps be made to cope.

Alasdair


