Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F29D1F4195
	for <lvm-devel@lists.linux.dev>; Wed, 19 Feb 2025 15:06:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1739977612; cv=none; b=t8U7EDTDtgVnQx0012sS1vzzKM52/ozAegEGaLUt/tyEIkz88MfSIfCGFPVM3td8wHH+U8N3g+mQK2LIYHU9BY1+AscrnssmccA6bbsh7WAzRGCJFHKxBp2FVp/7Fzp73McfJoZSuJfW6F/r4Urzzk3iibVNqGC93svDcgSHzZA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1739977612; c=relaxed/simple;
	bh=GLYVIMjhhykW8P6QX1riyMdPpVJNFMpET+n3pvLxn2E=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=K2+oiNVCNWNI8cu+ASFitnGl9uMZ9knKp1vZPbr2taPs6ArDFHX270v88a8iiWvZz/n/wi47npIHzzzeIFp2Vxy4kZrHKNWyU8LtwaheP5GNjhSUxfeYj81pMvgORDzNOrJJrj3ttXBMv9UvN9bBlXpFtN4YT1/nnsqUpYfzC5o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=X3jf5KMQ; arc=none smtp.client-ip=209.85.128.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X3jf5KMQ"
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-43937cf2131so46289435e9.2
        for <lvm-devel@lists.linux.dev>; Wed, 19 Feb 2025 07:06:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1739977609; x=1740582409; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=QX6ofGtYEgQZ8XDq+fc30VcX6i3t56cBcldCdN7gB9k=;
        b=X3jf5KMQgHecXsAHJt7yvuM+9mGM3Kv4BfmrqwHi4qMcItCqDU0OYtrxV9Vg5zkjaf
         fUvK+XCWtGRB3+qvZSg9IhuUe9r9dxJtJiXShY7X/OZp2RpsOP2+zKuix/Atcjuqnce1
         Nmm8QhV0lYpVEyVyFT4ESG/pECjZ6kqKoXbqNFKdpOPxJGKg6KgK3RXXf3iKDmUxpFlx
         41GAz2rSFneHmxvGC4bwtr7hXpcHRf7Sxa+RVAgVfqAqhIg8lK1ahNCeRHCBtcglBuhG
         P8Ck0GDbSDTK5Qm87KaShpYEyoH8ce6Ud2qlRJjBo6NVKbrs5SjfMkXbEC3Po5EKYC+u
         Te/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1739977609; x=1740582409;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=QX6ofGtYEgQZ8XDq+fc30VcX6i3t56cBcldCdN7gB9k=;
        b=inDe1fzOiPUByoJIShPc1+mF6sOeh3vGHw8Z2r4gwUoG6ZzNc/FOmcUeCoY9GQXsYN
         E768r+Q+xhExxsG8R9dhcsRm60XFogrTJ6VHRJXYrmDS7my7tinS7kxLZQweI05hwPKt
         86WDS0GDm1x1Sd+Uvm2cvV0O/uHZ9Lz6wdMmsYkC1Ucbd+htgZEe7kchWSP54weW7e5b
         ZxH1rjTIxX5UH/3dptZ7zpVqkz16iasZaHP1yM3I9w18PO3imPbtERDMlaho5MQ0S60D
         m5bv7S5QIhkEfF0/Te0WU/b3uAn97QtGEaqFD5M9ZmUrbCx8Xd6cUP+/tvS/iXsFuZRu
         RR+Q==
X-Forwarded-Encrypted: i=1; AJvYcCWxxQ8nB6ZHn1mpkvAHsfPbthV3vSqn1h3ITqecLuVgmr8LtNItLQkEFEN4D788c6CGVv/2L5Nc9Bc=@lists.linux.dev
X-Gm-Message-State: AOJu0Yzw1raeBeZ8mPV552ry8oO8WNnxHtX7UTkDdaLQeg5cZkNlKO99
	Z98Mw1r2Y8iD84VM9KYagT0QpWqCkles2LAfNwCQ6UI6aWzvLXBCr+WUNT1o
X-Gm-Gg: ASbGnctdR2RmvCPqTHIaPVEdpAb3wRcuyxhgrVGrv3pmP5FVKwtctFiv65yDpv0j0Pn
	KDUJvpIS9ISB05gKRC89trMpRG2Uxx1jk110LjJOgn69iKEpOU4uX2XG41eZa+TscV2IHELL66o
	h3DVgxnel7O3K8e0gIDTAy2N2rx6pkDIjF5djNulkSipJKWgS2k2oDlnIv/nSsuyLizXv9h33Fi
	Rxi3SdIlr9m2N0mDl8Ubjm5wUOCr10khuqOdCUbXKYlALeewBD1mEYG0c0xNVSF2aNa+GsA3Gmf
	4tpPD/0Gd0KUpjgV/5D3GIlrjut4ElblIlgqp+G6KDKiSWvLqtSlGLKfRUh1EGameMPisQ==
X-Google-Smtp-Source: AGHT+IGbNluYX6P5Q9KLLPGVvgsOXNslnY8dEsV+yl/pXPi+NU7cb+hGCw5kwQLEAzFhoFymnlb6sg==
X-Received: by 2002:a05:600c:548a:b0:439:a093:fffe with SMTP id 5b1f17b1804b1-439a09402abmr11712275e9.7.1739977608242;
        Wed, 19 Feb 2025 07:06:48 -0800 (PST)
Received: from ?IPV6:2a03:a900:1000:7e9:403e:7c8b:351b:f333? ([2a03:a900:1000:7e9:403e:7c8b:351b:f333])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-439948eb34esm51686345e9.38.2025.02.19.07.06.46
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 19 Feb 2025 07:06:47 -0800 (PST)
Message-ID: <c1d5760e-ee5f-40f8-825f-4c7f44a0aacf@gmail.com>
Date: Wed, 19 Feb 2025 16:06:45 +0100
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Fix the issue of missing symbols in libdevmapper
To: "zengjianqi163@163.co" <zengjianqi163@163.com>, lvm-devel@lists.linux.dev
References: <2299fe3d.6a77.1951d2e7409.Coremail.zengjianqi163@163.com>
Content-Language: en-US, cs
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
In-Reply-To: <2299fe3d.6a77.1951d2e7409.Coremail.zengjianqi163@163.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Dne 19. 02. 25 v 8:48 zengjianqi163@163.co napsal(a):
> Hi，lvm-devel
> 
> I analyzed the dynamic library libdevmapper.so.1.02 and found an issue: it 
> appears to be missing two symbols: dm_bitset_parse_list@@DM_1_02_138 and 
> dm_tree_node_size_changed@Base.
> 
> Analysis of dm_bitset_parse_list@@DM_1_02_138:
> 
> The symbol dm_bitset_parse_list is listed in the files 
> libdm/.exported_symbols.DM_1_02_129 and libdm/.exported_symbols.DM_1_02_138. 
> However, in the actual source code implementation, only 
> dm_bitset_parse_list@@DM_1_02_129 is explicitly defined.

Yep - thanks for the patch.

I'm just wondering how did you hit the issue - is this from some other 
libdevmapper user ?

(As lvm2 is using it's internal copy these days - so there cannot be a problem 
with linking this symbol within lvm2.)

Regards

Zdenek

