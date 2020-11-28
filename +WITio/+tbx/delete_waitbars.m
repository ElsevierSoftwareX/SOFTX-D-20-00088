function delete_waitbars(),
    delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
end
