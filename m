From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Nov 2010 13:33:55 +0100
Subject: [PATCH 29/29] Check for NULL pointer
In-Reply-To: <20101129224750.GT29380@agk-dp.fab.redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>	<5aaa9a83ca612d4594736d7b7c34dcd5adc0a611.1290682013.git.zkabelac@redhat.com>	<4CEEEB09.5050508@redhat.com>
	<20101129224750.GT29380@agk-dp.fab.redhat.com>
Message-ID: <4CF4EF33.8020105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.11.2010 23:47, Alasdair G Kergon napsal(a):
> On Fri, Nov 26, 2010 at 12:02:33AM +0100, Zdenek Kabelac wrote:
>> +	default:
>> +		log_error(INTERNAL_ERROR "Unknown report type.");
>> +		return ECMD_FAILED;
> 
> It's an enum where we cover every value.  An assertion is frankly
> pointless.
> 
> I could equally perform my own 'static analysis' and deduce that the
> default case there is redundant and delete it:)
> 


Of course for our code all cases are covered - and as I've mentioned  -
sometimes the analyzer is not yet skilled enough to recognize that all
use-cases of the function are already covered and there cannot be any misusage
as the function is invoked only locally (static) - but usually all 'asserts()'
are about something which should never happen :)

Anyway I'll open another Clang bug for this case.

(as you may see I'm usually being suggested to cover the problematic case by
adding asserts (i.e. see http://llvm.org/bugs/show_bug.cgi?id=8697))

It's about whether we want to get all these 'easy-to-hide' false positives
again with next round check - so anyone who will look into the result of
analyzer will need to go through the list of 'old known' problems - or just
directly see a new problem - i.e. having multiple pages of issues where some
of them are known false positives - currently with my local tree I get just
23 reports - which is pretty small list)

It's not a problem to keep these little quirks only in my local tree (except
we wont get cleaner Coverity reports as that one is made with CVS tree).

Zdenek



