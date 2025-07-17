Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAE3E1A3177
	for <lvm-devel@lists.linux.dev>; Thu, 17 Jul 2025 19:47:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1752781659; cv=none; b=LaXFgQu166kgag/PtMFQA7zdxjirB0r/2TT5i/LUM3/NjdSWXSuJEENA6rOeJinwi+19sReX3Vhg7hBtgBm9LXbMTIeyhH0X1RJuVscwlAUR5CdKvuQNXaY6zepwMDqIJl4qJTo6I/bq0zvnBBrj7g47Ad8AQTniLIZXgHOJf4o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1752781659; c=relaxed/simple;
	bh=qeTvwpCdep68Dhzoo20sauehrGi2jd06n5C6f9n+GH4=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=nc++ZsRJf6E1LaZWygyLcKuCaWFgVjs1yMEBXIlPDdSrMkadlEuFntd/nrDnQjqfN44oQApbeS1liMc7UMhRlK1KKNk14D4rvjD7eaQgdU0+5YXnFko9ARMMRsKcFRQMUKFlX59GaeyK5CIXDGrW/Qi+2R9zdTyLeORv9hcvtpo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=dUbLhp0X; arc=none smtp.client-ip=209.85.221.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dUbLhp0X"
Received: by mail-wr1-f41.google.com with SMTP id ffacd0b85a97d-3a57ae5cb17so719876f8f.0
        for <lvm-devel@lists.linux.dev>; Thu, 17 Jul 2025 12:47:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1752781656; x=1753386456; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=i3PrYFnOvT1hDy2WYgro2PBqn+UQrndsYsjsrraoJSI=;
        b=dUbLhp0XqxKskzopXRI9VGK0+BFsFqOKi8EReYfqgu2PEf3rAwoJk4VLS+pt4TqRdp
         Z0GzkBwcjfHjwR0It+3K3fu7FP71ATICg098SyU+v7+mDQc7ly+BLhRYHYf9ykraP7t0
         Q4iW7GFq5N/svhcxSYgUE3XQZ9jZB91KXsWgr4FJ9RUcA44JoUotFtJKbahbxgqJeMCf
         o8xFawBIeiewXEz93MuDxDiIXEmW6ROVMLHfBCpYGyyl7M+QrrayvNHD5ZPdtfhiu8lA
         zA7ah351hrrPmDlqkjwTgfgRU18+W59UBFFMY5Yc5aEsqCSPtdCR3osX/p7U6Tw8AL0V
         fHig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1752781656; x=1753386456;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=i3PrYFnOvT1hDy2WYgro2PBqn+UQrndsYsjsrraoJSI=;
        b=FVEhR8cVT6JQcDJB8OlVMLErPhGmRlgZXJaOsYVunMHXB6dWPq+g7WXQtSuAMtRAuP
         QEg8lxk8zz8w8ZW+qib9pJnx4zO9gfl5LnhTesz0cLBcGB/PyY3xUpY9FPPmpXdkYi/5
         XQZm1zl0P5Apaybk5MOjIC1fWcF5H8d2f+DXQe7o6aN+toRYFuxD3gXT5tEZ7PGesxnf
         xHVxW21zsGnl5SZFUYGzQudsIIAqHHZrz4DQ0ZhO3uPz/kNbnnC235tF+pzFQzTXdf00
         H/RbiKyI5ss05DQ1gTNE5VxLwtMC8sqDZzptHXxCW1h7xcp7NtF23iwvZGsSuHx7BlUP
         QEFg==
X-Forwarded-Encrypted: i=1; AJvYcCW2WtcBaWkOUVPzTPQdxKww2LWuKZilODoDrcnSXvh62n+TFtd2RZGIgipdowMW16Ci7FK4u5ZE9Pc=@lists.linux.dev
X-Gm-Message-State: AOJu0Yzeh3bxdZx5m/cX9JPzvEAO9GxxPb2cmFHmz6UCpnlJsKncCmxu
	hAgJy+5WfSZAH9x0LI4NfmAfBcFA39rhuMguNZ7EEvHAxe/uBS/yRrGU
X-Gm-Gg: ASbGncv0E5iH4kbTuSawba/MG8X1vsJBKqa0U9RW+Njdu69NhbTNE0+pEoGMSweBW0c
	6agRh0b21cv6KbKE7lm7iTiNbjmLlDiPIW9m68/XImvSuKM7SlbtOEKlNVJXOhcXv7r663eumJf
	vJaqFq3RqUts3+jGqA5eYV3jzNAsAgqHJ1ngiSTk5n4RuSsdLRrnUsOtAeCJZNTowTDiVZ2h5/0
	uvR2YjNuUdvbLal9vpl0sWJOjNr1SUHDeVpbNZ6hXlZI2/JWiEIbA1w3mZOD9GBKsGKYt0ADW5P
	rUvdNy5yafnzHw/SAb4FxjKWNeCRu63c5+gCOc2vstW2lOgT+7avAqq15yrLZYQK/GJivRqkGfx
	h9Ic/aA/NYHAIgnwR4sbgMcXpwKsECDfKeFO0IubNON2Ev2FERu3X/qYl88uY5swvaBnUShtmu6
	UJzA==
X-Google-Smtp-Source: AGHT+IGIWbUxnbcqueDicP2i5m0seIRka2JQPkBfslo+Z1iM3e1+q3pk+EM7P9jAzvZU+JBovgMPUQ==
X-Received: by 2002:a05:6000:41f6:b0:3a4:ddde:13e4 with SMTP id ffacd0b85a97d-3b60e539d4bmr5321335f8f.58.1752781655682;
        Thu, 17 Jul 2025 12:47:35 -0700 (PDT)
Received: from ?IPV6:2a03:a900:1000:7e9:c971:864a:7fa9:5c6e? ([2a03:a900:1000:7e9:c971:864a:7fa9:5c6e])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4562e8860cdsm60842985e9.20.2025.07.17.12.47.34
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 17 Jul 2025 12:47:35 -0700 (PDT)
Message-ID: <56ba968e-974b-43d2-889b-b530572bfcfd@gmail.com>
Date: Thu, 17 Jul 2025 21:47:34 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: a/an fixups
To: Andre Beaud <abacct2002@gmail.com>, lvm-devel@lists.linux.dev
References: <8ab673ba-3824-4bc2-af83-9e1a04e06316@gmail.com>
Content-Language: en-US, cs
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
In-Reply-To: <8ab673ba-3824-4bc2-af83-9e1a04e06316@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 05. 07. 25 v 17:03 Andre Beaud napsal(a):
> Hi lvm-devel,
> 
> 
> When looking through some output today from lvdisplay -vv, I came across a bit 
> language that needed looking at - something like
> 
> "Adding some/path:6781 as an user of ..."
> 
> 
> After some grepping this led me to some a/an fixups along with a couple more 
> odds and ends. Hopefully this is useful like this as plain diff output, or let 
> me know if something else will work better.

Hi

Thanks for patch - it's been pushed upstream (slightly changed) as

https://gitlab.com/lvmteam/lvm2/-/commit/cfeeee9b3d79aa51e81a72ee3d0b01c802c70469

Regards

Zdenek

