# ssh(1) completion

have ssh || return

_ssh_ciphers()
{
    COMPREPLY+=( $( compgen -W '3des-cbc aes128-cbc \
        aes192-cbc aes256-cbc aes128-ctr aes192-ctr aes256-ctr arcfour128 \
        arcfour256 arcfour blowfish-cbc cast128-cbc' -- "$cur" ) )
}

_ssh_macs()
{
    COMPREPLY+=( $( compgen -W 'hmac-md5 hmac-sha1 \
        umac-64@openssh.com hmac-ripemd160 hmac-sha1-96 hmac-md5-96' \
        -- "$cur" ) )
}

_ssh_options()
{
    compopt -o nospace
    COMPREPLY=( $( compgen -S = -W 'AddressFamily BatchMode BindAddress \
        ChallengeResponseAuthentication CheckHostIP Cipher Ciphers \
        ClearAllForwardings Compression CompressionLevel ConnectionAttempts \
        ConnectTimeout ControlMaster ControlPath DynamicForward EscapeChar \
        ExitOnForwardFailure ForwardAgent ForwardX11 ForwardX11Trusted \
        GatewayPorts GlobalKnownHostsFile GSSAPIAuthentication \
        GSSAPIDelegateCredentials HashKnownHosts Host HostbasedAuthentication \
        HostKeyAlgorithms HostKeyAlias HostName IdentityFile IdentitiesOnly \
        KbdInteractiveDevices LocalCommand LocalForward LogLevel MACs \
        NoHostAuthenticationForLocalhost NumberOfPasswordPrompts \
        PasswordAuthentication PermitLocalCommand Port \
        PreferredAuthentications Protocol ProxyCommand PubkeyAuthentication \
        RekeyLimit RemoteForward RhostsRSAAuthentication RSAAuthentication \
        SendEnv ServerAliveInterval ServerAliveCountMax SmartcardDevice \
        StrictHostKeyChecking TCPKeepAlive Tunnel TunnelDevice \
        UsePrivilegedPort User UserKnownHostsFile VerifyHostKeyDNS \
        VisualHostKey XAuthLocation' -- "$cur" ) )
}

# Complete a ssh suboption (like ForwardAgent=y<tab>)
# Only one parameter: the string to complete including the equal sign.
# Not all suboptions are completed.
# Doesn't handle comma-separated lists.
_ssh_suboption()
{
    # Split into subopt and subval
    local prev=${1%%=*} cur=${1#*=}

    case $prev in
        BatchMode|ChallengeResponseAuthentication|CheckHostIP|\
        ClearAllForwardings|Compression|ExitOnForwardFailure|ForwardAgent|\
        ForwardX11|ForwardX11Trusted|GatewayPorts|GSSAPIAuthentication|\
        GSSAPIKeyExchange|GSSAPIDelegateCredentials|GSSAPITrustDns|\
        HashKnownHosts|HostbasedAuthentication|IdentitiesOnly|\
        KbdInteractiveAuthentication|KbdInteractiveDevices|\
        NoHostAuthenticationForLocalhost|PasswordAuthentication|\
        PubkeyAuthentication|RhostsRSAAuthentication|RSAAuthentication|\
        StrictHostKeyChecking|TCPKeepAlive|UsePrivilegedPort|\
        VerifyHostKeyDNS|VisualHostKey)
            COMPREPLY=( $( compgen -W 'yes no' -- "$cur") )
            ;;
        AddressFamily)
            COMPREPLY=( $( compgen -W 'any inet inet6' -- "$cur" ) )
            ;;
        BindAddress)
            _ip_addresses
            ;;
        Cipher)
            COMPREPLY=( $( compgen -W 'blowfish des 3des' -- "$cur" ) )
            ;;
        Protocol)
            COMPREPLY=( $( compgen -W '1 2 1,2 2,1' -- "$cur" ) )
            ;;
        Tunnel)
            COMPREPLY=( $( compgen -W 'yes no point-to-point ethernet' \
                    -- "$cur" ) )
            ;;
        PreferredAuthentications)
            COMPREPLY=( $( compgen -W 'gssapi-with-mic host-based \
                    publickey keyboard-interactive password' -- "$cur" ) )
            ;;
        MACs)
            _ssh_macs
            ;;
        Ciphers)
            _ssh_ciphers
            ;;
    esac
    return 0
}

# Try to complete -o SubOptions=
#
# Returns 0 if the completion was handled or non-zero otherwise.
_ssh_suboption_check()
{
    # Get prev and cur words without splitting on =
    local cureq=`_get_cword :=` preveq=`_get_pword :=`
    if [[ $cureq == *=* && $preveq == -o ]]; then
        _ssh_suboption $cureq
        return $?
    fi
    return 1
}

_ssh()
{
    local cur prev words cword
    _init_completion -n : || return

    local configfile
    local -a config

    _ssh_suboption_check && return 0

    case $prev in
        -F|-i|-S)
            _filedir
            return 0
            ;;
        -c)
            _ssh_ciphers
            return 0
            ;;
        -m)
            _ssh_macs
            return 0
            ;;
        -l)
            COMPREPLY=( $( compgen -u -- "$cur" ) )
            return 0
            ;;
        -o)
            _ssh_options
            return 0
            ;;
        -w)
            _available_interfaces
            return 0
            ;;
        -b)
            _ip_addresses
            return 0
            ;;
        -D|-e|-I|-L|-O|-p|-R|-W)
            return 0
            ;;
    esac

    if [[ "$cur" == -F* ]]; then
        cur=${cur#-F}
        _filedir
        # Prefix completions with '-F'
        COMPREPLY=( "${COMPREPLY[@]/#/-F}" )
        cur=-F$cur  # Restore cur
    elif [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '$( _parse_usage "$1" )' -- "$cur" ) )
    else
        # Search COMP_WORDS for '-F configfile' or '-Fconfigfile' argument
        set -- "${words[@]}"
        while [ $# -gt 0 ]; do
            if [ "${1:0:2}" = -F ]; then
                if [ ${#1} -gt 2 ]; then
                    configfile="$(dequote "${1:2}")"
                else
                    shift
                    [ "$1" ] && configfile="$(dequote "$1")"
                fi
                break
            fi
            shift
        done
        _known_hosts_real -a -F "$configfile" "$cur"
        if [ $cword -ne 1 ]; then
            compopt -o filenames
            COMPREPLY+=( $( compgen -c -- "$cur" ) )
        fi
    fi

    return 0
} &&
shopt -u hostcomplete && complete -F _ssh ssh slogin autossh

# sftp(1) completion
#
_sftp()
{
    local cur prev words cword
    _init_completion || return

    local configfile

    _ssh_suboption_check && return 0

    case $prev in
        -b|-F|-i)
            _filedir
            return 0
            ;;
        -o)
            _ssh_options
            return 0
            ;;
        -c)
            _ssh_ciphers
            return 0
            ;;
        -B|-D|-P|-R|-S|-s)
            return 0
            ;;
    esac

    if [[ "$cur" == -F* ]]; then
        cur=${cur#-F}
        _filedir
        # Prefix completions with '-F'
        COMPREPLY=( "${COMPREPLY[@]/#/-F}" )
        cur=-F$cur  # Restore cur
    elif [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '$( _parse_usage "$1" )' -- "$cur" ) )
    else
        # Search COMP_WORDS for '-F configfile' argument
        set -- "${words[@]}"
        while [ $# -gt 0 ]; do
            if [ "${1:0:2}" = -F ]; then
                if [ ${#1} -gt 2 ]; then
                    configfile="$(dequote "${1:2}")"
                else
                    shift
                    [ "$1" ] && configfile="$(dequote "$1")"
                fi
                break
            fi
            shift
        done
        _known_hosts_real -a -F "$configfile" "$cur"
    fi

    return 0
} &&
shopt -u hostcomplete && complete -F _sftp sftp

# things we want to backslash escape in scp paths
_scp_path_esc='[][(){}<>",:;^&!$=?`|\\'"'"'[:space:]]'

# Complete remote files with ssh.  If the first arg is -d, complete on dirs
# only.  Returns paths escaped with three backslashes.
_scp_remote_files()
{
    local IFS=$'\n'

    # remove backslash escape from the first colon
    cur=${cur/\\:/:}

    local userhost=${cur%%?(\\):*}
    local path=${cur#*:}

    # unescape (3 backslashes to 1 for chars we escaped)
    path=$( sed -e 's/\\\\\\\('$_scp_path_esc'\)/\\\1/g' <<<"$path" )

    # default to home dir of specified user on remote host
    if [ -z "$path" ]; then
        path=$(ssh -o 'Batchmode yes' $userhost pwd 2>/dev/null)
    fi

    local files
    if [ "$1" = -d ] ; then
        # escape problematic characters; remove non-dirs
        files=$( ssh -o 'Batchmode yes' $userhost \
            command ls -aF1d "$path*" 2>/dev/null | \
            sed -e 's/'$_scp_path_esc'/\\\\\\&/g' -e '/[^\/]$/d' )
    else
        # escape problematic characters; remove executables, aliases, pipes
        # and sockets; add space at end of file names
        files=$( ssh -o 'Batchmode yes' $userhost \
            command ls -aF1d "$path*" 2>/dev/null | \
            sed -e 's/'$_scp_path_esc'/\\\\\\&/g' -e 's/[*@|=]$//g' \
            -e 's/[^\/]$/& /g' )
    fi
    COMPREPLY+=( $files )
}

# This approach is used instead of _filedir to get a space appended
# after local file/dir completions, and -o nospace retained for others.
# If first arg is -d, complete on directory names only.  The next arg is
# an optional prefix to add to returned completions.
_scp_local_files()
{
    local IFS=$'\n'

    local dirsonly=false
    if [ "$1" = -d ]; then
        dirsonly=true
        shift
    fi

    if $dirsonly ; then
        COMPREPLY+=( $( command ls -aF1d $cur* 2>/dev/null | \
            sed -e "s/$_scp_path_esc/\\\\&/g" -e '/[^\/]$/d' -e "s/^/$1/") )
    else
        COMPREPLY+=( $( command ls -aF1d $cur* 2>/dev/null | \
            sed -e "s/$_scp_path_esc/\\\\&/g" -e 's/[*@|=]$//g' \
            -e 's/[^\/]$/& /g' -e "s/^/$1/") )
    fi
}

# scp(1) completion
#
_scp()
{
    local cur prev words cword
    _init_completion -n : || return

    local configfile prefix

    _ssh_suboption_check && {
        COMPREPLY=( "${COMPREPLY[@]/%/ }" )
        return 0
    }

    case $prev in
        -l|-P)
            return 0
            ;;
        -F|-i|-S)
            _filedir
            compopt +o nospace
            return 0
            ;;
        -c)
            _ssh_ciphers
            COMPREPLY=( "${COMPREPLY[@]/%/ }" )
            return 0
            ;;
        -o)
            _ssh_options
            return 0
            ;;
    esac

    _expand || return 0

    if [[ "$cur" == *:* ]]; then
        _scp_remote_files
        return 0
    fi

    if [[ "$cur" == -F* ]]; then
        cur=${cur#-F}
        prefix=-F
    else
        # Search COMP_WORDS for '-F configfile' or '-Fconfigfile' argument
        set -- "${words[@]}"
        while [ $# -gt 0 ]; do
            if [ "${1:0:2}" = -F ]; then
                if [ ${#1} -gt 2 ]; then
                    configfile="$(dequote "${1:2}")"
                else
                    shift
                    [ "$1" ] && configfile="$(dequote "$1")"
                fi
                break
            fi
            shift
        done

        case $cur in
            -*)
                COMPREPLY=( $( compgen -W '$( _parse_usage "${words[0]}" )' \
                    -- "$cur" ) )
                COMPREPLY=( "${COMPREPLY[@]/%/ }" )
                return 0
                ;;
            */*|[.~]*)
                # not a known host, pass through
                ;;
            *)
                _known_hosts_real -c -a -F "$configfile" "$cur"
                ;;
        esac
    fi

    _scp_local_files "$prefix"

    return 0
} &&
complete -F _scp -o nospace scp

# ssh-copy-id(1) completion
#
_ssh_copy_id()
{
    local cur prev words cword
    _init_completion || return

    case $prev in
        -i)
            _filedir
            return 0
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '$( _parse_usage "$1" --help )' -- "$cur" ) )
    else
        _known_hosts_real -a "$cur"
    fi

    return 0
} &&
complete -F _ssh_copy_id ssh-copy-id

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh
