Received: from mail.gathman.org (mail.gathman.org [174.64.33.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 878521E32A2;
	Thu,  7 Aug 2025 04:58:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=174.64.33.221
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754542723; cv=none; b=pn34Y2dW390MLVBvJaSnLEcirUWBBcrtKzwfnpzQbmupawCbOrjpgnfj4wduykiq5SwZNnJVJSOCXtnovZ+LIYkOoIQmRu94ANp7AhCCXco0XDesuvdiY9KWIirjWxVnpsqSJzmZJvB6sHFfHleNEnBezZXCP8TU9Qrgi75zeKY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754542723; c=relaxed/simple;
	bh=xFAYluQuzYB6Myda9x6z3bW/68zOm17bZ4sXkDXMLa8=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=PKBAMw5FkJ8gIgv4Bc4DNO6rQr1XNl6tfyqSneDipFD2paoycuwp57zin9Lo2o621+C750CYzhxv8Ah7loIIeTXH45d1qATuMU+uHoeccynjReKoGuFme5QywreQW6n6ZzSQ3DD/K37HFA6j1bKEsl5ELN0Cm9sbgcY09AjtEro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gathman.org; spf=pass smtp.mailfrom=gathman.org; dkim=pass (1024-bit key) header.d=gathman.org header.i=@gathman.org header.b=fqY9svIN; arc=none smtp.client-ip=174.64.33.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gathman.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gathman.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gathman.org header.i=@gathman.org header.b="fqY9svIN"
Authentication-Results: mail.gathman.org; iprev=pass policy.iprev="2001:470:8:809::1010" (wiki.gathman.org); auth=pass (CRAM-MD5 sslbits=256) smtp.auth=stuart
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gathman.org; 
 i=@gathman.org; q=dns/txt; s=default; t=1754540589; 
 h=date : from : to : cc : subject : in-reply-to : 
 message-id : references : mime-version : content-type : 
 date : from : subject; 
 bh=xFAYluQuzYB6Myda9x6z3bW/68zOm17bZ4sXkDXMLa8=; 
 b=fqY9svINaEBBP7QAE6QS48TlU9amcsxI5qdfcNTntQMphNtoWg1LczaU
 QlwBsuX6rvBKHkJUEUanXieHBsmsFApSBHQybYEhxr0j0OUoFNAbKgV0RS
 tWuvQzx6uSo80mS48x9r3O9jQPxDHLpK/2GZcOX0ivDFdicVVeFoUuWA0=
Received: from wiki.gathman.org (wiki.gathman.org [IPv6:2001:470:8:809::1010])
	(authenticated bits=0)
	by mail.gathman.org (8.14.7/8.14.7) with ESMTP id 5774N6c1026490
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 7 Aug 2025 00:23:09 -0400
Date: Thu, 7 Aug 2025 00:23:06 -0400 (EDT)
From: Stuart D Gathman <stuart@gathman.org>
To: John Stoffel <john@stoffel.org>
cc: Mikulas Patocka <mpatocka@redhat.com>, Peter Rajnoha <prajnoha@redhat.com>,
        Zdenek Kabelac <zkabelac@redhat.com>,
        Heinz Mauelshagen <heinzm@redhat.com>,
        David Teigland <teigland@redhat.com>, linux-lvm@lists.linux.dev,
        lvm-devel@lists.linux.dev
Subject: Re: [PATCH] fix random failures in shell/integrity.sh
In-Reply-To: <26771.51188.491376.658337@quad.stoffel.home>
Message-ID: <65919799-842c-9428-8bfc-5c1c0671338@gathman.org>
References: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com> <26771.51188.491376.658337@quad.stoffel.home>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed

On Wed, 6 Aug 2025, John Stoffel wrote:

>>>>>> "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:
>
>> The problem is that the raid1 implementation may freely choose which leg
>> to read from. If it chooses to read from the non-corrupted leg, the
>> corruption is not detected, the number of mismatches is not incremented
>> and the test reports this as a failure.
>
> So wait, how is integrity supposed to work in this situation then?  In
> real life?  I understand the test is hard, maybe doing it in a loop
> three times?  Or configure the RAID1 to prefer one half over another
> is the way to make this test work?

Linux needs an optional parameter to read() syscall that is "leg index"
for the blk interface.  Thus, btrfs scrub can check all legs, and this
test can check all legs.  Filesystems with checks can repair corruption
by rewriting the block after finding a leg with correct csum.

This only needs a few bits (how many legs can there be?), so can go in
the FLAGS argument.

