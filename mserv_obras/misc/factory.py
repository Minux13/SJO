

class Factory(object):
    """
    Base class to implement a factory pattern
    """

    # Database for the several inceptors
    _inceptors = {}

    @staticmethod
    def is_supported(i):
        """
        Verifies if there is an inceptor available at index.

        Args:
            i (obj): any hashable object instance as index.

        Returns:
            bool: answer to the question asked
        """
        ic = Factory._inceptors.get(i, None)
        return False if not ic else True

    @staticmethod
    def subscribe(i, ic):
        """
        Place an inceptor class upon one slot index of
        the inceptors database

        Args:
            i  (obj)  : any hashable object instance as index.
            ic (class): inceptor class to subscribe.

        Returns:
            Nothing (None)
        """
        Factory._inceptors[i] = ic

    @staticmethod
    def incept(i):
        """
        Incepts an instance of the class living
        within the slot index

        Args:
            i  (obj): any hashable object instance as index.

        Returns:
            An instance of the object contained within
            the slot index otherwise nothing (None)
        """
        ic = Factory._inceptors.get(i, None)
        return None if ic is None else ic()