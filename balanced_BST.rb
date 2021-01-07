require 'pry'

class Node
    include Comparable

    attr_accessor :data,:left_child,:right_child
    def initialize(data=nil,left_child=nil,right_child=nil)
        @data = data
        @left_child = left_child
        @right_child = right_child
    end

    # def <=>(node)
    #     data <=> node.data
    # end
end

class Tree
    attr_accessor :tree, :root
    def initialize(tree=[],root=nil)
        @tree = tree
        @root = root
    end

    def pretty_print(node = @root, prefix = '', is_left = true)
        pretty_print(node.right_child, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right_child
        puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
        pretty_print(node.left_child, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left_child
    end
    
    def self.merge_sort (array)
        if array.length < 2
            return array
        else
    
            left_half = merge_sort(array[0..(array.length-1)/2])
            right_half = merge_sort(array[((array.length-1)/2)+1..-1])
    
            sorted = []
            left_half.each do |x|
                until right_half.length == 0 || x < right_half[0]
                    sorted << right_half[0]
                    right_half = right_half.drop(1)
                    if right_half.length == 0
                        break
                    end
                end
                sorted << x
            end
            if right_half.length>0
                right_half.each do |x|
                    sorted << x
                end
            end
            return sorted
        end
    end

    def self.remove_duplicates(array)
        cleaned = []

        array.each do |item|
            cleaned << item unless cleaned.include?(item)
        end

        return cleaned
    end
        
    def build_and_sort(array)
        sorted = self.class.merge_sort(self.class.remove_duplicates(array))
        build_tree(sorted,0,sorted.length-1)
    end

    def build_tree(array, arr_start, arr_end)
        
        if arr_start>arr_end
            return nil
        else
            middle = (arr_end+arr_start)/2
            root = array[middle]

            left_tree = build_tree(array,arr_start,middle-1)
            right_tree = build_tree(array,middle+1,arr_end)
            node = Node.new(root,left_tree,right_tree)
            @tree << node
            @root = node
        end
    end

    def insert(value, root=self.root)
        compare = root.data <=> value

        if compare == 1
            if root.left_child == nil 
                root.left_child = Node.new(value)
            elsif root.left_child.data < value
                node = Node.new(value,root.left_child)
                root.left_child = node
            else
                insert(value,root.left_child)
            end
        elsif compare == -1
            if root.right_child == nil
                root.right_child = Node.new(value)
            elsif root.right_child.data > value
                node = Node.new(value,nil,root.right_child)
                root.right_child = node
            else
                insert(value,root.right_child)
            end
        elsif compare == 0
            return nil
        end
    end

    def delete(value, root=nil, child=self.root)
        compare = child.data <=> value

        if compare == 1
            if child.left_child == nil || child.left_child.data < value
                return nil
            else
                delete(value,child,child.left_child)
            end
        elsif compare == -1
            if child.right_child == nil || child.right_child.data > value
                return nil
            else
                delete(value,child,child.right_child)
            end
        elsif compare == 0
            unless root == nil
                if child == root.left_child
                    root.left_child = child.right_child == nil ? child.left_child : child.right_child
                elsif child == root.right_child
                    root.right_child = child.right_child == nil ? child.left_child : child.right_child
                end
            end
            @tree.slice!(@tree.index(child))
        end
    end

    def find(value,root=self.root)
        compare = root.data <=> value

        if compare == 1
            if root.left_child == nil
                return nil
            else
                find(value,root.left_child)
            end
        elsif compare == -1
            if root.right_child == nil
                return nil
            else
                find(value,root.right_child)
            end
        elsif compare == 0
            return root
        end
    end

    def level_order()
        queue = []
        final = []
        queue << self.root
        while queue.length > 0
            queue << queue[0].left_child unless queue[0].left_child == nil
            queue << queue[0].right_child unless queue[0].right_child == nil
            final << queue.shift.data
        end
        return final
    end

    def inorder(root=self.root)
        final = []
        left = root.left_child == nil ? root.left_child : inorder(root.left_child)
        right = root.right_child == nil ? root.right_child : inorder(root.right_child)
        
        unless left == nil
            final << left
        end
        final << root.data
        unless right == nil
            final << right
        end
        return final.flatten
    end

    def preorder(root=self.root)
        final = []
        final << root.data

        left = root.left_child == nil ? root.left_child : preorder(root.left_child)
        right = root.right_child == nil ? root.right_child : preorder(root.right_child)
        
        unless left == nil
            final << left
        end
        unless right == nil
            final << right
        end
        return final.flatten
    end

    def postorder(root=self.root)
        final = []

        left = root.left_child == nil ? root.left_child : postorder(root.left_child)
        right = root.right_child == nil ? root.right_child : postorder(root.right_child)
        
        unless left == nil
            final << left
        end
        unless right == nil
            final << right
        end
        final << root.data
        return final.flatten
    end

    def height(node=self.root)
        return -1 if node == nil
        [height(node.left_child), height(node.right_child)].max + 1
    end

    def depth(node,root=self.root)
        compare = root.data <=> node.data

        if compare == 1
            if root.left_child == nil
                return 0
            else
                depth(node,root.left_child) + 1
            end
        elsif compare == -1
            if root.right_child == nil
                return 0
            else
                depth(node,root.right_child) + 1
            end
        elsif compare == 0
            return 0
        end
    end

    def balanced?(node = self.root)
        return true if node.nil?
    
        left_height = height(node.left_child)
        right_height = height(node.right_child)
    
        return true if (left_height - right_height).abs <= 1 && balanced?(node.left_child) && balanced?(node.right_child)
    
        false
    end

    def rebalance()
        build_and_sort(self.inorder)
    end
end

test = Tree.new()
test.build_and_sort((Array.new(15) { rand(1..100) }))
p test.balanced?
p test.level_order
p test.inorder
p test.preorder
p test.postorder
10.times do test.insert(rand(100..200)) end
p test.balanced?
test.rebalance
p "rebalanced"
p test.balanced?
p test.level_order
p test.inorder
p test.preorder
p test.postorder
