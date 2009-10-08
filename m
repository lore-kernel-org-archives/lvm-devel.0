From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Oct 2009 00:34:13 +0100
Subject: [PATCH 04/11] debian: fix implicit pointer
In-Reply-To: <3b7fddbbcca36451e4b8e3617ab54c6e5839877a.1255002311.git.fdinitto@redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<3b7fddbbcca36451e4b8e3617ab54c6e5839877a.1255002311.git.fdinitto@redhat.com>
Message-ID: <20091008233412.GS3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 08, 2009 at 02:49:11PM +0200, Fabio M. Di Nitto wrote:
> not sure why the ifdef does not fire, but this is a readline function
> and must not be redefined
 
This hack was needed for compilation on some systems (functions renamed
in library).

If there are other systems where it causes problems, then please
send details.

Alasdair


