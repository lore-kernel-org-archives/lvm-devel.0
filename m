From: Milan Broz <mbroz@redhat.com>
Date: Thu, 12 Aug 2010 11:09:38 +0200
Subject: [PATCH] clvmd init exit 4 when executed by non-root user
In-Reply-To: <4C63B731.90407@redhat.com>
References: <4C63B731.90407@redhat.com>
Message-ID: <4C63BA52.10300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/12/2010 10:56 AM, Fabio M. Di Nitto wrote:
> Once again and hopefully for the last time..
> 
> clvmd daemon itself does the right thing when invoked as non-root, by
> returning 4.
> 
> The patch removes the use daemon function from
> /etc/rc.d/init.d/functions that?s unnecessary and has the bad habit to
> mask the return codes from the real daemon.

ack.

(and I wonder how is this daemon function is
LSB/FedoraGuidlines/UltimateQuestionOfLife compliant:-)

Milan


