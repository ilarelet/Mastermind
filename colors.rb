class String
    #possible background for text
        def bg_black;       "\e[40m#{self}\e[0m" end
        def bg_red;         "\e[41m#{self}\e[0m" end
        def bg_green;       "\e[42m#{self}\e[0m" end
        def bg_brown;       "\e[43m#{self}\e[0m" end
        def bg_blue;        "\e[44m#{self}\e[0m" end
        def bg_magenta;     "\e[45m#{self}\e[0m" end
        def bg_cyan;        "\e[46m#{self}\e[0m" end
        def bg_gray;        "\e[47m#{self}\e[0m" end
    #red font for results
        def red;            "\e[31m#{self}\e[0m" end
    end