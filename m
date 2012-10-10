From: Petr Rockai <prockai@redhat.com>
Date: Wed, 10 Oct 2012 12:12:58 +0200
Subject: [PATCH]: Allow limited metadata changes when PVs are missing
In-Reply-To: <1349840815.32340.6.camel@f16> (Jonathan Brassow's message of
	"Tue, 09 Oct 2012 22:46:55 -0500")
References: <1349840815.32340.6.camel@f16>
Message-ID: <87txu2r5xx.fsf@aldalome.mornfall.net>
	(sfid-20121010_121259_226031_DDC14B84)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Jonathan Brassow <jbrassow@redhat.com> writes:
> The solution is to allow vgchange and lvchange to alter the LVM metadata
> for a limited set of options - --[add|del]tag included.  The set of
> allowable options are ones that do not cause changes to the DM kernel
> target (like --resync would) or could alter the structure of the LV
> (like allocation or conversion).

seems OK to me. Nevertheless, I would like to see a functional test
along with the patch, to make sure the newly allowed options actually
work as expected. Other than the missing test, ACK.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


