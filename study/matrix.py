def element(x, y, width):
    return (y * width + x) * 4

def create_matrix(width, height):
    matrix = []

    for y in range(height):
        row = []
        for x in range(width):
            row.append(element(x, y, width))
        matrix.append(row)

    return matrix

def print_matrix(matrix):
    w = len(matrix[0])
    indexes_row = [str(i).ljust(3).rjust(5) for i in range(w)]

    print(" " * 6, end="|")
    for index in indexes_row:
        print(index, end=" |")
    
    print()

    for i in range(len(matrix)):
        row = matrix[i]

        print(("-" * w * 8) + "--")
        
        row_index = str(i).ljust(3).rjust(4)
        print("|", row_index, end="")

        print("|", end=" ")

        for element in row:
            str_element_padded = str(element).ljust(3).rjust(4)
            print(str_element_padded, end=" | ")
            # print("|")
        print()
    print(("-" * w * 8) + "--")

def main():
    matrix = create_matrix(5, 5)

    print_matrix(matrix)

if __name__ == '__main__':
    main()