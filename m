From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Oct 2009 00:35:22 +0100
Subject: [PATCH 05/11] debian: keep libdm-abi consistent
In-Reply-To: <58b1e4d3fbc50afac900c970b6d1fa6819391946.1255002311.git.fdinitto@redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<58b1e4d3fbc50afac900c970b6d1fa6819391946.1255002311.git.fdinitto@redhat.com>
Message-ID: <20091008233522.GT3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 08, 2009 at 02:49:12PM +0200, Fabio M. Di Nitto wrote:
> don't change the ABI of libdm on selinux enable, just make the selinux
> function a NOP
 
Clearly this needs fixing upstream.

Alasdair


