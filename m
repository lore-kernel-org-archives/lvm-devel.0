From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Oct 2009 00:27:25 +0100
Subject: [PATCH 01/11] debian: fix library search path in example.conf
In-Reply-To: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
References: <1255002904-6226-1-git-send-email-fdinitto@redhat.com>
	<8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
Message-ID: <20091008232725.GP3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 08, 2009 at 01:54:54PM +0200, Fabio M. Di Nitto wrote:
> this patch is debian specific and sets the library search path
> to /lib/lvm2 to avoid cluttering /lib
 
Add configure parm for this and generate example.conf from template?

In fact, it would be useful to know the current 'configure' line that
Debian uses.

Alasdair


