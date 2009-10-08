From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Oct 2009 00:44:50 +0100
Subject: [PATCH 08/11] debian: use selinux pkgconfig info instead of hardcoding
In-Reply-To: <afcb9c9c64ef9416639b7c508add1e519a62fbb7.1255002311.git.fdinitto@redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<afcb9c9c64ef9416639b7c508add1e519a62fbb7.1255002311.git.fdinitto@redhat.com>
Message-ID: <20091008234450.GW3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 08, 2009 at 02:49:15PM +0200, Fabio M. Di Nitto wrote:
> use selinux pkgconfig file instead of hardcoding the contents
 
I don't think this patch goes far enough...
The build should be using the pc file too (if present), as we now do for clvmd!

Alasdair


