From: Przemyslaw Iskra <sparky@pld-linux.org>
Date: Sat, 7 Aug 2010 03:51:11 +0200
Subject: [PATCH] Don't use floor() in _bitset_with_random_bits
In-Reply-To: <87hbj7k0iy.fsf@twilight.int.mornfall.net.>
References: <20100730170535.GA21519@pld-linux.org>
	<87hbj7k0iy.fsf@twilight.int.mornfall.net.>
Message-ID: <20100807015111.GA25844@pld-linux.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Aug 06, 2010 at 09:24:05PM +0200, Petr Rockai wrote:
> Hi,
> 
> Przemyslaw Iskra <sparky@pld-linux.org> writes:
> > Use _even_rand() function instead of floor() in
> > _bitset_with_random_bits(). floor() function is missing in dietlibc (on
> > architectures other than x86). Moreover using floor() to clip rand
> > results does not assure even result distribution.
> > _even_rand() uses integer arithmetic only and is designed to return evenly
> > distributed results.
> >
> > Signed-off-by: Przemyslaw Iskra <sparky@pld-linux.org>
> 
> Reviewed-by: Petr Rockai <prockai@redhat.com>
> 
> Looks OK to me. It took a while to decipher what is the exact meaning of
> the loop in _even_rand (to a non-pseudorandomness-expert) but I am
> fairly comfortable with it now. If I understand this correctly, it
> rejects numbers that come from an "incomplete" slice of the RAND_MAX
> space (considering the number space [0, RAND_MAX] is divided into some
> "max"-sized slices and at most a single smaller slice, between [n*max,
> RAND_MAX] for suitable n -- numbers from this last slice are discarded
> because they could distort the distribution in favour of smaller
> numbers).

That's exactly what it does.

However, right now it cutts off the last slice even if it's complete.
You could replace:

> > +	} while ( r - ret >= RAND_MAX - max );

With:

+	} while ( r - ret > (unsigned) RAND_MAX + 1 - max );

Result distribution is correct in both cases. It just avoids the branch
in 0.00something %.


Przemyslaw Iskra

-- 
 ____  Sparky{PI] -- Przemyslaw _  ___  _  _  ......... LANG...Pl,Ca,Es,En
/____) ___  ___  _ _ || Iskra  |  | _ \| |  | : WWW...ppcrcd.pld-linux.org
\____\| -_)'___| ||^'||//\\// <   |  _/| |  | : WWW2..............rsget.pl
(____/||   (_-_|_||  ||\\ ||   |_ |_|  |_| _| : Mail..sparky@pld-linux.org


