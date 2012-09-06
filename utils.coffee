exports.greatest_factor = (number, max = 'auto', min = 1) ->
        if max == 'auto'
                max = Math.floor Math.sqrt number
        for i in [max..min]
                b = number / i
                if b == parseInt b
                        return i
        return min